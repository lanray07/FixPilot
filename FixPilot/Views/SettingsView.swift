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
                    LabeledContent("AI mode", value: "Mock only")
                    Text("This release does not send issue notes, property details, or photos to any third-party AI service.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
                    NavigationLink("Privacy policy") { LegalTextView(title: "Privacy Policy", text: LegalCopy.privacy) }
                    NavigationLink("Terms of use") { LegalTextView(title: "Terms of Use", text: LegalCopy.terms) }
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

private enum LegalCopy {
    static let privacy = """
    FixPilot AI Maintenance stores property, maintenance issue, inspection, repair cost, reminder, report, and photo evidence data locally on your device.

    The current version does not collect personal data on developer-operated servers. Camera and photo library access are used only when you choose to attach photo evidence to maintenance issues or inspections. Local notifications are scheduled on device for maintenance reminders.

    AI features run in mock mode in this release. FixPilot does not send issue notes, property details, inspection notes, repair records, photos, or any other personal data to OpenAI, ChatGPT, or any third-party AI service. If a future version enables remote AI processing, the app will first explain what data is sent, identify who receives it, request user permission before sending it, and update this privacy policy.

    Subscriptions are handled by Apple's StoreKit and App Store systems.

    Privacy Policy:
    https://github.com/lanray07/FixPilot/blob/main/PRIVACY.md
    """

    static let terms = """
    FixPilot AI Maintenance uses Apple's standard End User License Agreement.

    Terms of Use (EULA):
    https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

    Auto-renewable subscriptions:
    Pro Monthly - $19.99 - renews monthly.
    Pro Yearly - $149.99 - renews yearly.
    Business Monthly - $79.99 - renews monthly.

    Payment is charged to your Apple ID at purchase confirmation. Subscriptions renew automatically unless canceled at least 24 hours before the end of the current period. You can manage or cancel subscriptions in your App Store account settings.
    """
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
