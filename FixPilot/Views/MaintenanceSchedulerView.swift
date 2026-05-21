import SwiftUI
import SwiftData

struct MaintenanceSchedulerView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var app: AppViewModel
    @Query(sort: \Property.name) private var properties: [Property]
    @Query(sort: \RecurringMaintenanceTask.nextDueDate) private var tasks: [RecurringMaintenanceTask]

    @State private var propertyId: UUID?
    @State private var title = "Boiler servicing"
    @State private var category = "Safety"
    @State private var frequency = MaintenanceFrequency.yearly
    @State private var nextDueDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @State private var scheduleReminder = true
    @State private var errorMessage: String?

    let presets = ["Boiler servicing", "HVAC servicing", "Fire alarm checks", "Smoke detector checks", "Gutter cleaning", "Pest control", "Roof inspections", "Appliance servicing", "Seasonal maintenance"]

    var body: some View {
        Form {
            Section("Recurring task") {
                if properties.isEmpty {
                    ContentUnavailableView("Add a property first", systemImage: "building.2", description: Text("Recurring maintenance needs a property."))
                } else {
                    Picker("Property", selection: Binding(get: { propertyId ?? properties.first?.id }, set: { propertyId = $0 })) {
                        ForEach(properties) { property in
                            Text(property.name).tag(Optional(property.id))
                        }
                    }
                    Picker("Preset", selection: $title) {
                        ForEach(presets, id: \.self) { Text($0).tag($0) }
                    }
                    TextField("Category", text: $category)
                    Picker("Frequency", selection: $frequency) {
                        ForEach(MaintenanceFrequency.allCases) { Text($0.rawValue).tag($0) }
                    }
                    DatePicker("Next due", selection: $nextDueDate, displayedComponents: .date)
                    Toggle("Local reminder", isOn: $scheduleReminder)
                }
            }

            Section("Upcoming") {
                if tasks.isEmpty {
                    Text("No recurring tasks yet.").foregroundStyle(.secondary)
                } else {
                    ForEach(tasks) { task in
                        ReminderCard(task: task)
                    }
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Maintenance")
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
        let task = RecurringMaintenanceTask(propertyId: propertyId, title: title, category: category, frequency: frequency, nextDueDate: nextDueDate)
        modelContext.insert(task)
        if scheduleReminder {
            Task {
                do {
                    try await app.notifications.requestAuthorization()
                    try await app.notifications.scheduleReminder(for: task)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
