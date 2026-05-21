import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var app: AppViewModel
    @EnvironmentObject private var subscription: SubscriptionStore
    @Query private var properties: [Property]
    @Query private var issues: [MaintenanceIssue]
    @Query private var photos: [IssuePhoto]
    @Query private var inspections: [Inspection]
    @Query private var checklistItems: [InspectionChecklistItem]
    @Query private var tasks: [RecurringMaintenanceTask]
    @Query private var costs: [RepairCostRecord]
    @Query private var reports: [MaintenanceReport]

    @State private var businessName = ""
    @State private var notificationsEnabled = true
    @State private var reportBranding = "FixPilot"
    @State private var confirmDelete = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Subscription") {
                    LabeledContent("Current plan", value: subscription.currentPlan.rawValue)
                    NavigationLink("Manage subscription") {
                        PaywallView()
                    }
                }

                Section("Business profile") {
                    TextField("Business name", text: $businessName)
                    TextField("Report branding", text: $reportBranding)
                    Toggle("Mock AI enabled", isOn: $app.mockAIEnabled)
                }

                Section("Notifications") {
                    Toggle("Local reminders", isOn: $notificationsEnabled)
                    Button("Request notification permission") {
                        Task { try? await app.notifications.requestAuthorization() }
                    }
                }

                Section("Data") {
                    ShareLink(item: exportText()) {
                        Label("Export data", systemImage: "square.and.arrow.up")
                    }
                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Label("Delete all local data", systemImage: "trash")
                    }
                }

                Section("Legal and safety") {
                    NavigationLink("Privacy policy") { LegalTextView(title: "Privacy Policy", text: "Placeholder privacy policy. Replace with your production privacy policy before release.") }
                    NavigationLink("Terms of use") { LegalTextView(title: "Terms of Use", text: "Placeholder terms of use. Replace with reviewed production terms before release.") }
                    NavigationLink("AI disclaimer") { LegalTextView(title: "AI Disclaimer", text: FixPilotDisclaimer.full) }
                }
            }
            .navigationTitle("Settings")
            .alert("Delete all local data?", isPresented: $confirmDelete) {
                Button("Delete", role: .destructive, action: deleteAllData)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes local properties, issues, photos, inspections, recurring tasks, costs, and reports from this device.")
            }
        }
    }

    private func exportText() -> String {
        """
        FixPilot local export
        Properties: \(properties.count)
        Issues: \(issues.count)
        Inspections: \(inspections.count)
        Recurring tasks: \(tasks.count)
        Repair costs: \(costs.count)
        Reports: \(reports.count)
        """
    }

    private func deleteAllData() {
        photos.forEach(modelContext.delete)
        checklistItems.forEach(modelContext.delete)
        costs.forEach(modelContext.delete)
        reports.forEach(modelContext.delete)
        tasks.forEach(modelContext.delete)
        inspections.forEach(modelContext.delete)
        issues.forEach(modelContext.delete)
        properties.forEach(modelContext.delete)
    }
}

private struct LegalTextView: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(title)
    }
}
