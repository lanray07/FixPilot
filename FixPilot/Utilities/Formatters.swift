import Foundation
import SwiftUI

extension IssueSeverity {
    var tint: Color {
        switch self {
        case .low: .green
        case .medium: .blue
        case .high: .orange
        case .urgent: .red
        }
    }
}

extension Decimal {
    func currency(_ code: String = "GBP") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
    }
}

extension Double {
    func currency(_ code: String = "GBP") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

enum FixPilotDisclaimer {
    static let short = "AI suggestions are informational only. Not engineering advice, structural certification, or legal advice."
    static let full = "AI suggestions are informational only and must be reviewed. FixPilot does not provide engineering advice, structural certification, legal advice, or licensed contractor guarantees. Urgent safety issues should be checked by qualified professionals immediately."
}
