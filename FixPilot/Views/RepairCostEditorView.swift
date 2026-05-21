import SwiftUI
import SwiftData

struct RepairCostEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let issue: MaintenanceIssue

    @State private var contractorName = ""
    @State private var laborCost = 0.0
    @State private var materialsCost = 0.0
    @State private var repairDate = Date()
    @State private var paymentStatus = PaymentStatus.pending

    var body: some View {
        Form {
            Section("Repair cost") {
                TextField("Contractor name", text: $contractorName)
                TextField("Labor cost", value: $laborCost, format: .number.precision(.fractionLength(2)))
                    .keyboardType(.decimalPad)
                TextField("Materials cost", value: $materialsCost, format: .number.precision(.fractionLength(2)))
                    .keyboardType(.decimalPad)
                DatePicker("Repair date", selection: $repairDate, displayedComponents: .date)
                Picker("Payment status", selection: $paymentStatus) {
                    ForEach(PaymentStatus.allCases) { Text($0.rawValue).tag($0) }
                }
                LabeledContent("Total", value: (laborCost + materialsCost).currency())
            }
        }
        .navigationTitle("Repair Cost")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    modelContext.insert(RepairCostRecord(
                        maintenanceIssueId: issue.id,
                        contractorName: contractorName,
                        laborCost: laborCost,
                        materialsCost: materialsCost,
                        repairDate: repairDate,
                        paymentStatus: paymentStatus
                    ))
                    dismiss()
                }
            }
        }
    }
}
