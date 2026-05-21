import SwiftUI
import SwiftData
import PhotosUI

struct IssuesView: View {
    @Query(sort: \Property.createdAt, order: .reverse) private var properties: [Property]
    @Query(sort: \MaintenanceIssue.createdAt, order: .reverse) private var issues: [MaintenanceIssue]

    var body: some View {
        NavigationStack {
            Group {
                if issues.isEmpty {
                    EmptyStateView(title: "No maintenance issues", message: "Report leaks, electrical faults, safety concerns, appliance problems, and general repairs.", systemImage: "wrench.adjustable")
                } else {
                    List(issues) { issue in
                        NavigationLink {
                            AIAssistantView(issue: issue)
                        } label: {
                            MaintenanceIssueCard(issue: issue, propertyName: properties.first(where: { $0.id == issue.propertyId })?.name ?? "Unassigned property")
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Issues")
            .toolbar {
                NavigationLink {
                    IssueEditorView(issue: nil)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Report issue")
            }
        }
    }
}

struct IssueEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Property.name) private var properties: [Property]
    let issue: MaintenanceIssue?

    @State private var propertyId: UUID?
    @State private var title = ""
    @State private var category = IssueCategory.generalRepair
    @State private var roomArea = ""
    @State private var severity = IssueSeverity.medium
    @State private var status = IssueStatus.open
    @State private var notes = ""
    @State private var reportedDate = Date()
    @State private var assignedContractor = ""
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var pendingPhotoData: [Data] = []
    @State private var showingCamera = false

    var body: some View {
        Form {
            if properties.isEmpty {
                Section {
                    ContentUnavailableView("Add a property first", systemImage: "building.2", description: Text("Issues need to be linked to a property."))
                }
            } else {
                Section("Issue") {
                    Picker("Property", selection: Binding(get: { propertyId ?? properties.first?.id }, set: { propertyId = $0 })) {
                        ForEach(properties) { property in
                            Text(property.name).tag(Optional(property.id))
                        }
                    }
                    TextField("Issue title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(IssueCategory.allCases) { Text($0.rawValue).tag($0) }
                    }
                    TextField("Room/area", text: $roomArea)
                    Picker("Severity", selection: $severity) {
                        ForEach(IssueSeverity.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Picker("Status", selection: $status) {
                        ForEach(IssueStatus.allCases) { Text($0.rawValue).tag($0) }
                    }
                    DatePicker("Reported", selection: $reportedDate, displayedComponents: .date)
                }

                Section("Details") {
                    TextField("Assigned contractor", text: $assignedContractor)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(4...10)
                }

                Section("Photos") {
                    PhotosPicker(selection: $selectedPhotoItems, matching: .images) {
                        Label("Upload photos", systemImage: "photo.on.rectangle")
                    }
                    Button {
                        showingCamera = true
                    } label: {
                        Label("Use camera", systemImage: "camera")
                    }
                    if !pendingPhotoData.isEmpty {
                        Text("\(pendingPhotoData.count) photo(s) ready to attach")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(issue == nil ? "Report Issue" : "Edit Issue")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || properties.isEmpty)
            }
        }
        .onAppear(perform: load)
        .onChange(of: selectedPhotoItems) { _, newValue in
            Task {
                pendingPhotoData = []
                for item in newValue {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        pendingPhotoData.append(data)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker { data in
                pendingPhotoData.append(data)
            }
        }
    }

    private func load() {
        propertyId = issue?.propertyId ?? properties.first?.id
        guard let issue else { return }
        title = issue.title
        category = IssueCategory(rawValue: issue.category) ?? .generalRepair
        roomArea = issue.roomArea
        severity = IssueSeverity(rawValue: issue.severity) ?? .medium
        status = IssueStatus(rawValue: issue.status) ?? .open
        notes = issue.notes
        reportedDate = issue.reportedDate
        assignedContractor = issue.assignedContractor
    }

    private func save() {
        guard let selectedPropertyId = propertyId ?? properties.first?.id else { return }
        let savedIssue: MaintenanceIssue
        if let issue {
            issue.propertyId = selectedPropertyId
            issue.title = title
            issue.category = category.rawValue
            issue.roomArea = roomArea
            issue.severity = severity.rawValue
            issue.status = status.rawValue
            issue.notes = notes
            issue.reportedDate = reportedDate
            issue.assignedContractor = assignedContractor
            savedIssue = issue
        } else {
            let newIssue = MaintenanceIssue(propertyId: selectedPropertyId, title: title, category: category, roomArea: roomArea, severity: severity, status: status, notes: notes, reportedDate: reportedDate, assignedContractor: assignedContractor)
            modelContext.insert(newIssue)
            savedIssue = newIssue
        }
        for data in pendingPhotoData {
            modelContext.insert(IssuePhoto(maintenanceIssueId: savedIssue.id, imageData: data))
        }
        dismiss()
    }
}

struct AIAssistantView: View {
    @EnvironmentObject private var app: AppViewModel
    @Query(sort: \Property.createdAt) private var properties: [Property]
    @Query(sort: \IssuePhoto.createdAt, order: .reverse) private var photos: [IssuePhoto]
    @StateObject private var viewModel = AIAnalysisViewModel()
    let issue: MaintenanceIssue

    private var property: Property? {
        properties.first { $0.id == issue.propertyId }
    }

    var body: some View {
        List {
            Section {
                MaintenanceIssueCard(issue: issue, propertyName: property?.name ?? "Unassigned property")
                DisclaimerBanner()
            }

            Section("AI maintenance assistant") {
                if viewModel.isLoading {
                    ProgressView("Reviewing visible maintenance details...")
                } else if let result = viewModel.result {
                    Text(result.summary)
                    LabeledContent("Priority", value: result.priorityLevel)
                    DisclosureGroup("Possible causes") {
                        ForEach(result.possibleCauses, id: \.self) { Text($0) }
                    }
                    DisclosureGroup("Recommended next steps") {
                        ForEach(result.recommendations, id: \.self) { Text($0) }
                    }
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("AI unavailable", systemImage: "wifi.exclamationmark", description: Text(error))
                } else {
                    Button {
                        Task { await runAnalysis() }
                    } label: {
                        Label("Analyze issue", systemImage: "sparkles")
                    }
                }
            }

            Section("Repair cost") {
                NavigationLink {
                    RepairCostEditorView(issue: issue)
                } label: {
                    Label("Add repair cost", systemImage: "sterlingsign.circle")
                }
            }
        }
        .navigationTitle("AI Assistant")
        .task {
            if viewModel.result == nil {
                await runAnalysis()
            }
        }
    }

    private func runAnalysis() async {
        let firstPhoto = photos.first { $0.maintenanceIssueId == issue.id }?.imageData
        await viewModel.analyze(issue: issue, property: property, imageData: firstPhoto, service: app.aiService)
    }
}
