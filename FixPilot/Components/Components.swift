import SwiftUI
import Charts

struct SeverityBadge: View {
    let severity: String

    var body: some View {
        let level = IssueSeverity(rawValue: severity) ?? .medium
        Text(level.rawValue)
            .font(.caption.weight(.semibold))
            .foregroundStyle(level.tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(level.tint.opacity(0.12), in: Capsule())
            .accessibilityLabel("Severity \(level.rawValue)")
    }
}

struct PropertyCard: View {
    let property: Property

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: "building.2.fill")
                    .font(.title2)
                    .foregroundStyle(.teal)
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.name).font(.headline)
                    Text(property.address).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Text(property.propertyType)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.teal.opacity(0.12), in: Capsule())
            }
            Text("\(property.roomCount) rooms")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
    }
}

struct MaintenanceIssueCard: View {
    let issue: MaintenanceIssue
    let propertyName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(issue.title).font(.headline)
                    Text("\(propertyName) • \(issue.roomArea)").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                SeverityBadge(severity: issue.severity)
            }
            HStack {
                Label(issue.category, systemImage: "wrench.and.screwdriver")
                Spacer()
                Text(issue.status)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
    }
}

struct InspectionCard: View {
    let inspection: Inspection
    let propertyName: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checklist.checked")
                .font(.title2)
                .foregroundStyle(.teal)
            VStack(alignment: .leading, spacing: 4) {
                Text(inspection.inspectionType).font(.headline)
                Text(propertyName).font(.subheadline).foregroundStyle(.secondary)
                Text(inspection.date.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(Int(inspection.score))")
                .font(.title3.weight(.bold))
                .foregroundStyle(inspection.score >= 80 ? .green : .orange)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
    }
}

struct ReminderCard: View {
    let task: RecurringMaintenanceTask

    var body: some View {
        HStack {
            Image(systemName: task.completed ? "checkmark.circle.fill" : "calendar.badge.clock")
                .foregroundStyle(task.completed ? .green : .teal)
            VStack(alignment: .leading) {
                Text(task.title).font(.headline)
                Text("\(task.frequency) • Due \(task.nextDueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
    }
}

struct CostSummaryCard: View {
    let title: String
    let amount: Double
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage).foregroundStyle(.teal)
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(amount.currency()).font(.title3.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
    }
}

struct AnalyticsChartCard: View {
    let costs: [RepairCostRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Repair spend").font(.headline)
            Chart(costs) { cost in
                BarMark(
                    x: .value("Date", cost.repairDate, unit: .month),
                    y: .value("Spend", cost.totalCost)
                )
                .foregroundStyle(.teal)
            }
            .frame(height: 180)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
    }
}

struct UpgradeBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(.teal)
            Text(message)
                .font(.subheadline.weight(.medium))
            Spacer()
        }
        .padding()
        .background(.teal.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: Text(message))
    }
}

struct DisclaimerBanner: View {
    var body: some View {
        Label(FixPilotDisclaimer.short, systemImage: "exclamationmark.shield")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding()
            .background(.yellow.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
    }
}
