import SwiftUI
import SwiftData

struct InspectionsView: View {
    @Query(sort: \Property.name) private var properties: [Property]
    @Query(sort: \Inspection.date, order: .reverse) private var inspections: [Inspection]

    var body: some View {
        NavigationStack {
            Group {
                if inspections.isEmpty {
                    EmptyStateView(title: "No inspections", message: "Create move-in, move-out, routine, turnover, safety, and seasonal inspections.", systemImage: "checklist")
                } else {
                    List(inspections) { inspection in
                        InspectionCard(inspection: inspection, propertyName: properties.first(where: { $0.id == inspection.propertyId })?.name ?? "Unassigned property")
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Inspections")
            .toolbar {
                NavigationLink {
                    InspectionEditorView()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New inspection")
            }
        }
    }
}

struct InspectionEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Property.name) private var properties: [Property]

    @State private var propertyId: UUID?
    @State private var inspectionType = InspectionType.routine
    @State private var date = Date()
    @State private var notes = ""
    @State private var checklist: [DraftChecklistItem] = DraftChecklistItem.defaults

    var score: Double {
        guard !checklist.isEmpty else { return 100 }
        return Double(checklist.filter(\.passed).count) / Double(checklist.count) * 100
    }

    var body: some View {
        Form {
            if properties.isEmpty {
                ContentUnavailableView("Add a property first", systemImage: "building.2", description: Text("Inspections need to be linked to a property."))
            } else {
                Section("Inspection") {
                    Picker("Property", selection: Binding(get: { propertyId ?? properties.first?.id }, set: { propertyId = $0 })) {
                        ForEach(properties) { property in
                            Text(property.name).tag(Optional(property.id))
                        }
                    }
                    Picker("Type", selection: $inspectionType) {
                        ForEach(InspectionType.allCases) { Text($0.rawValue).tag($0) }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    LabeledContent("Score", value: "\(Int(score))%")
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Checklist") {
                    ForEach($checklist) { $item in
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(item.title, isOn: $item.passed)
                            TextField("Notes", text: $item.notes, axis: .vertical)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .navigationTitle("New Inspection")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(properties.isEmpty)
            }
        }
        .onAppear {
            propertyId = propertyId ?? properties.first?.id
        }
    }

    private func save() {
        guard let propertyId = propertyId ?? properties.first?.id else { return }
        let inspection = Inspection(propertyId: propertyId, inspectionType: inspectionType, date: date, notes: notes, score: score)
        modelContext.insert(inspection)
        for item in checklist {
            modelContext.insert(InspectionChecklistItem(inspectionId: inspection.id, title: item.title, passed: item.passed, notes: item.notes))
        }
        dismiss()
    }
}

struct DraftChecklistItem: Identifiable {
    let id = UUID()
    var title: String
    var passed: Bool = true
    var notes: String = ""

    static let defaults = [
        DraftChecklistItem(title: "Walls, ceilings, and floors checked"),
        DraftChecklistItem(title: "Plumbing fixtures visually checked"),
        DraftChecklistItem(title: "Electrical fittings visually checked"),
        DraftChecklistItem(title: "Heating/cooling equipment visually checked"),
        DraftChecklistItem(title: "Smoke and safety devices checked"),
        DraftChecklistItem(title: "Photos captured where needed")
    ]
}
