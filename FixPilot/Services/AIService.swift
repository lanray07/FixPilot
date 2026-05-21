import Foundation

enum FixPilotAIPrompt {
    static let system = "You are FixPilot, an AI assistant for property maintenance management. Review uploaded property photos, issue descriptions, inspection notes, and maintenance details. Identify visible, non-diagnostic maintenance concerns only. Do not provide legal advice, engineering certification, structural certification, or licensed contractor guarantees. Use cautious language such as 'possible', 'visible sign of', and 'recommend professional inspection' where appropriate."
}

struct AIAnalysisResult: Codable, Equatable {
    var summary: String
    var possibleCauses: [String]
    var recommendations: [String]
    var priorityLevel: String
}

protocol AIService {
    func analyzeMaintenanceIssue(propertyType: String, issueCategory: String, severity: String, notes: String, imageBase64: String?) async throws -> AIAnalysisResult
    func generateInspectionSummary(type: String, notes: String, failedItems: [String]) async throws -> String
    func generateMaintenanceRecommendations(propertyType: String, issues: [MaintenanceIssue], tasks: [RecurringMaintenanceTask]) async throws -> [String]
    func generateRepairPriorityList(issues: [MaintenanceIssue]) async throws -> [String]
    func generateReportText(property: Property, issues: [MaintenanceIssue], inspections: [Inspection], costs: [RepairCostRecord]) async throws -> String
}

enum AIServiceError: LocalizedError {
    case invalidEndpoint
    case badResponse

    var errorDescription: String? {
        switch self {
        case .invalidEndpoint: "The backend AI endpoint is not configured."
        case .badResponse: "The AI service returned an invalid response."
        }
    }
}

final class MockAIService: AIService {
    func analyzeMaintenanceIssue(propertyType: String, issueCategory: String, severity: String, notes: String, imageBase64: String?) async throws -> AIAnalysisResult {
        AIAnalysisResult(
            summary: "Visible signs suggest a possible \(issueCategory.lowercased()) maintenance issue in this \(propertyType.lowercased()). The reported severity is \(severity.lowercased()).",
            possibleCauses: [
                "Possible age-related wear or failed component.",
                "Visible sign of moisture, deterioration, or repeated use depending on the affected area.",
                "Possible installation, ventilation, or servicing gap."
            ],
            recommendations: [
                "Recommend professional inspection before confirming the cause.",
                "Document the area with dated photos and keep access clear for a contractor.",
                "Contractor recommendation placeholder: match this record to an approved trade partner in your backend workflow.",
                "If there is an immediate safety risk, arrange urgent qualified support immediately."
            ],
            priorityLevel: severity == IssueSeverity.urgent.rawValue ? "Urgent" : severity
        )
    }

    func generateInspectionSummary(type: String, notes: String, failedItems: [String]) async throws -> String {
        let failed = failedItems.isEmpty ? "No failed checklist items were recorded." : "Review required for: \(failedItems.joined(separator: ", "))."
        return "\(type) completed. \(failed) Notes: \(notes.isEmpty ? "No additional notes." : notes) AI suggestions are informational only and should be reviewed by a qualified professional where needed."
    }

    func generateMaintenanceRecommendations(propertyType: String, issues: [MaintenanceIssue], tasks: [RecurringMaintenanceTask]) async throws -> [String] {
        [
            "Keep recurring safety checks current and record completion dates.",
            "Prioritize urgent and high severity items before cosmetic work.",
            "For \(propertyType.lowercased()) properties, maintain photo evidence and contractor notes for every completed repair.",
            tasks.contains(where: { !$0.completed && $0.nextDueDate < .now }) ? "Some recurring tasks appear overdue; schedule them before adding new discretionary work." : "No overdue recurring task pattern detected in local records."
        ]
    }

    func generateRepairPriorityList(issues: [MaintenanceIssue]) async throws -> [String] {
        issues
            .sorted { IssueSeverity(rawValue: $0.severity)?.rank ?? 0 > IssueSeverity(rawValue: $1.severity)?.rank ?? 0 }
            .map { "\($0.severity): \($0.title) - recommend professional review for this possible \($0.category.lowercased()) issue." }
    }

    func generateReportText(property: Property, issues: [MaintenanceIssue], inspections: [Inspection], costs: [RepairCostRecord]) async throws -> String {
        let spend = costs.reduce(0.0) { $0 + $1.totalCost }
        return """
        FixPilot maintenance summary for \(property.name).

        Open/local issue records: \(issues.count).
        Inspection records: \(inspections.count).
        Recorded repair spend: \(spend.currency()).

        AI-generated observations are informational only. This report is not engineering advice, structural certification, legal advice, or a licensed contractor guarantee. Urgent safety issues should be checked by qualified professionals immediately.
        """
    }
}

final class RemoteAIService: AIService {
    private let endpoint = URL(string: "https://YOUR_BACKEND_URL.com/fixpilot-ai")
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func analyzeMaintenanceIssue(propertyType: String, issueCategory: String, severity: String, notes: String, imageBase64: String?) async throws -> AIAnalysisResult {
        guard let endpoint else { throw AIServiceError.invalidEndpoint }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode([
            "propertyType": propertyType,
            "issueCategory": issueCategory,
            "severity": severity,
            "notes": notes,
            "imageBase64": imageBase64 ?? ""
        ])
        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw AIServiceError.badResponse }
        return try JSONDecoder().decode(AIAnalysisResult.self, from: data)
    }

    func generateInspectionSummary(type: String, notes: String, failedItems: [String]) async throws -> String {
        "Remote inspection summary placeholder. Route this through your secure backend before enabling production AI."
    }

    func generateMaintenanceRecommendations(propertyType: String, issues: [MaintenanceIssue], tasks: [RecurringMaintenanceTask]) async throws -> [String] {
        ["Remote recommendations placeholder. Never store API keys in the iOS app."]
    }

    func generateRepairPriorityList(issues: [MaintenanceIssue]) async throws -> [String] {
        issues.map { "\($0.severity): \($0.title)" }
    }

    func generateReportText(property: Property, issues: [MaintenanceIssue], inspections: [Inspection], costs: [RepairCostRecord]) async throws -> String {
        "Remote report text placeholder for \(property.name)."
    }
}
