import SwiftUI
import SwiftData

struct ReportsCenterView: View {
    @Query(sort: \MaintenanceReport.createdAt, order: .reverse) private var reports: [MaintenanceReport]
    @State private var searchText = ""

    private var filteredReports: [MaintenanceReport] {
        guard !searchText.isEmpty else { return reports }
        return reports.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.summary.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if reports.isEmpty {
                    EmptyStateView(title: "No reports", message: "Generate inspection and maintenance PDFs for owners, clients, contractors, or records.", systemImage: "doc.richtext")
                } else {
                    List(filteredReports) { report in
                        ReportPreviewView(report: report)
                    }
                }
            }
            .navigationTitle("Reports")
            .searchable(text: $searchText)
            .toolbar {
                NavigationLink {
                    ReportGeneratorView()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Generate report")
            }
        }
    }
}

struct ReportGeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var app: AppViewModel
    @EnvironmentObject private var subscription: SubscriptionStore
    @Query(sort: \Property.name) private var properties: [Property]
    @Query(sort: \MaintenanceIssue.createdAt, order: .reverse) private var issues: [MaintenanceIssue]
    @Query(sort: \Inspection.createdAt, order: .reverse) private var inspections: [Inspection]
    @Query(sort: \RepairCostRecord.repairDate, order: .reverse) private var costs: [RepairCostRecord]

    @State private var propertyId: UUID?
    @State private var isGenerating = false
    @State private var generatedURL: URL?
    @State private var errorMessage: String?

    private var selectedProperty: Property? {
        properties.first { $0.id == (propertyId ?? properties.first?.id) }
    }

    var body: some View {
        Form {
            Section("Report") {
                if properties.isEmpty {
                    ContentUnavailableView("Add a property first", systemImage: "building.2", description: Text("Reports need property details."))
                } else {
                    Picker("Property", selection: Binding(get: { propertyId ?? properties.first?.id }, set: { propertyId = $0 })) {
                        ForEach(properties) { property in
                            Text(property.name).tag(Optional(property.id))
                        }
                    }
                    DisclaimerBanner()
                }
            }

            if !subscription.hasProAccess {
                Section {
                    UpgradeBanner(message: "PDF exports are a Pro feature. This scaffold lets you test export locally before connecting StoreKit products.")
                }
            }

            Section {
                Button {
                    Task { await generate() }
                } label: {
                    if isGenerating {
                        ProgressView()
                    } else {
                        Label("Generate PDF", systemImage: "doc.badge.plus")
                    }
                }
                .disabled(properties.isEmpty || isGenerating)

                if let generatedURL {
                    ShareLink(item: generatedURL) {
                        Label("Share PDF", systemImage: "square.and.arrow.up")
                    }
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Generate Report")
        .onAppear {
            propertyId = propertyId ?? properties.first?.id
        }
    }

    private func generate() async {
        guard let property = selectedProperty else { return }
        isGenerating = true
        defer { isGenerating = false }
        do {
            let propertyIssues = issues.filter { $0.propertyId == property.id }
            let propertyInspections = inspections.filter { $0.propertyId == property.id }
            let relatedCosts = costs.filter { cost in propertyIssues.contains(where: { $0.id == cost.maintenanceIssueId }) }
            let summary = try await app.aiService.generateReportText(property: property, issues: propertyIssues, inspections: propertyInspections, costs: relatedCosts)
            let url = try app.pdf.generate(property: property, issues: propertyIssues, inspections: propertyInspections, costs: relatedCosts, summary: summary)
            generatedURL = url
            modelContext.insert(MaintenanceReport(propertyId: property.id, title: "\(property.name) Maintenance Report", summary: summary, pdfLocalURL: url))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ReportPreviewView: View {
    let report: MaintenanceReport

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(report.title).font(.headline)
            Text(report.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(report.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            if let url = report.pdfLocalURL {
                ShareLink(item: url) {
                    Label("Export PDF", systemImage: "square.and.arrow.up")
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 6)
    }
}
