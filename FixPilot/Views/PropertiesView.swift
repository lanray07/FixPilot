import SwiftUI
import SwiftData

struct PropertiesView: View {
    @Query(sort: \Property.createdAt, order: .reverse) private var properties: [Property]

    var body: some View {
        NavigationStack {
            Group {
                if properties.isEmpty {
                    EmptyStateView(title: "No properties", message: "Add a property to start tracking issues, inspections, repairs, and reports.", systemImage: "building.2")
                } else {
                    List(properties) { property in
                        NavigationLink {
                            PropertyEditorView(property: property)
                        } label: {
                            PropertyCard(property: property)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Properties")
            .toolbar {
                NavigationLink {
                    PropertyEditorView(property: nil)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add property")
            }
        }
    }
}

struct PropertyEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let property: Property?

    @State private var name = ""
    @State private var address = ""
    @State private var propertyType = PropertyType.apartment
    @State private var roomCount = 1
    @State private var ownerName = ""
    @State private var notes = ""

    var body: some View {
        Form {
            Section("Property") {
                TextField("Property name", text: $name)
                TextField("Address", text: $address, axis: .vertical)
                Picker("Type", selection: $propertyType) {
                    ForEach(PropertyType.allCases) { Text($0.rawValue).tag($0) }
                }
                Stepper("Rooms: \(roomCount)", value: $roomCount, in: 1...200)
            }

            Section("Owner or client") {
                TextField("Owner/client details", text: $ownerName)
                TextField("Maintenance notes", text: $notes, axis: .vertical)
                    .lineLimit(3...8)
            }
        }
        .navigationTitle(property == nil ? "Add Property" : "Edit Property")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let property else { return }
        name = property.name
        address = property.address
        propertyType = PropertyType(rawValue: property.propertyType) ?? .apartment
        roomCount = property.roomCount
        ownerName = property.ownerName
        notes = property.notes
    }

    private func save() {
        if let property {
            property.name = name
            property.address = address
            property.propertyType = propertyType.rawValue
            property.roomCount = roomCount
            property.ownerName = ownerName
            property.notes = notes
        } else {
            modelContext.insert(Property(name: name, address: address, propertyType: propertyType, roomCount: roomCount, ownerName: ownerName, notes: notes))
        }
        dismiss()
    }
}
