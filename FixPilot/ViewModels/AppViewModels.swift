import Foundation
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }
    @Published var selectedUserType: String {
        didSet { UserDefaults.standard.set(selectedUserType, forKey: "selectedUserType") }
    }
    @Published var selectedPropertyCount: String {
        didSet { UserDefaults.standard.set(selectedPropertyCount, forKey: "selectedPropertyCount") }
    }
    let mockAI = MockAIService()
    let notifications = NotificationService()
    let pdf = PDFReportService()

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        selectedUserType = UserDefaults.standard.string(forKey: "selectedUserType") ?? UserType.landlord.rawValue
        selectedPropertyCount = UserDefaults.standard.string(forKey: "selectedPropertyCount") ?? "1"
    }

    var aiService: AIService {
        mockAI
    }
}

@MainActor
final class AIAnalysisViewModel: ObservableObject {
    @Published var result: AIAnalysisResult?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func analyze(issue: MaintenanceIssue, property: Property?, imageData: Data?, service: AIService) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            result = try await service.analyzeMaintenanceIssue(
                propertyType: property?.propertyType ?? "Property",
                issueCategory: issue.category,
                severity: issue.severity,
                notes: issue.notes,
                imageBase64: imageData?.base64EncodedString()
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
