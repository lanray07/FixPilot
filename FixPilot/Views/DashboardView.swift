import SwiftUI
import SwiftData

struct DashboardView: View {
    @EnvironmentObject private var subscription: SubscriptionStore
    @Query(sort: \Property.createdAt, order: .reverse) private var properties: [Property]
    @Query(sort: \MaintenanceIssue.createdAt, order: .reverse) private var issues: [MaintenanceIssue]
    @Query(sort: \Inspection.createdAt, order: .reverse) private var inspections: [Inspection]
    @Query(sort: \RecurringMaintenanceTask.nextDueDate) private var tasks: [RecurringMaintenanceTask]
    @Query(sort: \RepairCostRecord.repairDate, order: .reverse) private var costs: [RepairCostRecord]
    @State private var path: [AppRoute] = []

    private var openIssues: [MaintenanceIssue] {
        issues.filter { IssueStatus(rawValue: $0.status)?.isOpen ?? true }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Dashboard").font(.largeTitle.weight(.bold))
                            Text("Maintenance control room").foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(subscription.currentPlan.rawValue)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.teal.opacity(0.12), in: Capsule())
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatTile(title: "Open issues", value: "\(openIssues.count)", icon: "exclamationmark.circle")
                        StatTile(title: "Urgent repairs", value: "\(issues.filter { $0.severity == IssueSeverity.urgent.rawValue }.count)", icon: "bolt.trianglebadge.exclamationmark")
                        StatTile(title: "Upcoming tasks", value: "\(tasks.filter { !$0.completed }.count)", icon: "calendar")
                        StatTile(title: "Properties", value: "\(properties.count)", icon: "building.2")
                    }

                    QuickActions(path: $path)

                    if !subscription.hasProAccess {
                        NavigationLink(value: AppRoute.paywall) {
                            UpgradeBanner(message: "Upgrade for AI assistant, recurring reminders, PDF exports, analytics, and unlimited tracking.")
                        }
                    }

                    if costs.isEmpty {
                        EmptyStateView(title: "No repair spend yet", message: "Add repair costs from issue records to populate analytics.", systemImage: "chart.bar")
                    } else {
                        AnalyticsChartCard(costs: costs)
                    }

                    SectionHeader("Recent issues")
                    ForEach(openIssues.prefix(4)) { issue in
                        NavigationLink {
                            AIAssistantView(issue: issue)
                        } label: {
                            MaintenanceIssueCard(issue: issue, propertyName: properties.first(where: { $0.id == issue.propertyId })?.name ?? "Unassigned property")
                        }
                        .buttonStyle(.plain)
                    }

                    SectionHeader("Recent inspections")
                    ForEach(inspections.prefix(3)) { inspection in
                        InspectionCard(inspection: inspection, propertyName: properties.first(where: { $0.id == inspection.propertyId })?.name ?? "Unassigned property")
                    }
                }
                .padding()
            }
            .navigationDestination(for: AppRoute.self) { destination in
                destinationView(destination)
            }
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: AppRoute) -> some View {
        switch destination {
        case .propertyEditor: PropertyEditorView(property: nil)
        case .issueEditor: IssueEditorView(issue: nil)
        case .inspectionEditor: InspectionEditorView()
        case .maintenanceScheduler: MaintenanceSchedulerView()
        case .reportGenerator: ReportGeneratorView()
        case .paywall: PaywallView()
        }
    }
}

private struct StatTile: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).foregroundStyle(.teal)
            Text(value).font(.title.weight(.bold))
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
    }
}

private struct QuickActions: View {
    @Binding var path: [AppRoute]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            QuickActionButton(title: "Report Issue", icon: "plus.circle.fill") { path.append(.issueEditor) }
            QuickActionButton(title: "New Inspection", icon: "checklist") { path.append(.inspectionEditor) }
            QuickActionButton(title: "Schedule Maintenance", icon: "calendar.badge.plus") { path.append(.maintenanceScheduler) }
            QuickActionButton(title: "Generate Report", icon: "doc.badge.plus") { path.append(.reportGenerator) }
            QuickActionButton(title: "Add Property", icon: "building.2.crop.circle") { path.append(.propertyEditor) }
        }
    }
}

private struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
    }
}

private struct SectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
