import SwiftUI
import SwiftData

@main
struct FixPilotApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var subscriptionStore = SubscriptionStore()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Property.self,
            MaintenanceIssue.self,
            IssuePhoto.self,
            Inspection.self,
            InspectionChecklistItem.self,
            RecurringMaintenanceTask.self,
            RepairCostRecord.self,
            MaintenanceReport.self,
            SubscriptionState.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appViewModel)
                .environmentObject(subscriptionStore)
        }
        .modelContainer(sharedModelContainer)
    }
}
