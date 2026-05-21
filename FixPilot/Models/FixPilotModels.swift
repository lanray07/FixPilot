import Foundation
import SwiftData

enum UserType: String, CaseIterable, Identifiable, Codable {
    case landlord = "Landlord"
    case propertyManager = "Property manager"
    case airbnbHost = "Airbnb host"
    case maintenanceContractor = "Maintenance contractor"
    case facilitiesManager = "Facilities manager"
    case buildingManager = "Building manager"

    var id: String { rawValue }
}

enum PropertyType: String, CaseIterable, Identifiable, Codable {
    case apartment = "Apartment"
    case house = "House"
    case airbnb = "Airbnb"
    case commercial = "Commercial"
    case office = "Office"
    case warehouse = "Warehouse"
    case retail = "Retail"
    case hmo = "HMO"
    case custom = "Custom"

    var id: String { rawValue }
}

enum IssueCategory: String, CaseIterable, Identifiable, Codable {
    case plumbing = "Plumbing"
    case electrical = "Electrical"
    case roofing = "Roofing"
    case heatingCooling = "Heating/Cooling"
    case dampMould = "Damp/Mould"
    case appliance = "Appliance"
    case flooring = "Flooring"
    case structuralVisualConcern = "Structural visual concern"
    case paintingDecor = "Painting/Decor"
    case pestIssue = "Pest issue"
    case safetyConcern = "Safety concern"
    case generalRepair = "General repair"

    var id: String { rawValue }
}

enum IssueSeverity: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"

    var id: String { rawValue }
    var rank: Int {
        switch self {
        case .low: 1
        case .medium: 2
        case .high: 3
        case .urgent: 4
        }
    }
}

enum IssueStatus: String, CaseIterable, Identifiable, Codable {
    case open = "Open"
    case scheduled = "Scheduled"
    case inProgress = "In Progress"
    case waitingParts = "Waiting Parts"
    case completed = "Completed"
    case closed = "Closed"

    var id: String { rawValue }
    var isOpen: Bool { ![Self.completed, Self.closed].contains(self) }
}

enum InspectionType: String, CaseIterable, Identifiable, Codable {
    case moveIn = "Move-in inspection"
    case moveOut = "Move-out inspection"
    case routine = "Routine inspection"
    case maintenanceCheck = "Maintenance check"
    case airbnbTurnover = "Airbnb turnover check"
    case safety = "Safety inspection"
    case seasonal = "Seasonal inspection"

    var id: String { rawValue }
}

enum MaintenanceFrequency: String, CaseIterable, Identifiable, Codable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case sixMonthly = "Every 6 months"
    case yearly = "Yearly"

    var id: String { rawValue }
}

enum PaymentStatus: String, CaseIterable, Identifiable, Codable {
    case unpaid = "Unpaid"
    case pending = "Pending"
    case paid = "Paid"

    var id: String { rawValue }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free = "Free"
    case pro = "Pro"
    case business = "Business"

    var id: String { rawValue }
}

@Model
final class Property {
    @Attribute(.unique) var id: UUID
    var name: String
    var address: String
    var propertyType: String
    var roomCount: Int
    var ownerName: String
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        propertyType: PropertyType,
        roomCount: Int,
        ownerName: String = "",
        notes: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.propertyType = propertyType.rawValue
        self.roomCount = roomCount
        self.ownerName = ownerName
        self.notes = notes
        self.createdAt = createdAt
    }
}

@Model
final class MaintenanceIssue {
    @Attribute(.unique) var id: UUID
    var propertyId: UUID
    var title: String
    var category: String
    var roomArea: String
    var severity: String
    var status: String
    var notes: String
    var reportedDate: Date
    var assignedContractor: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        propertyId: UUID,
        title: String,
        category: IssueCategory,
        roomArea: String,
        severity: IssueSeverity,
        status: IssueStatus = .open,
        notes: String = "",
        reportedDate: Date = .now,
        assignedContractor: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.propertyId = propertyId
        self.title = title
        self.category = category.rawValue
        self.roomArea = roomArea
        self.severity = severity.rawValue
        self.status = status.rawValue
        self.notes = notes
        self.reportedDate = reportedDate
        self.assignedContractor = assignedContractor
        self.createdAt = createdAt
    }
}

@Model
final class IssuePhoto {
    @Attribute(.unique) var id: UUID
    var maintenanceIssueId: UUID
    @Attribute(.externalStorage) var imageData: Data?
    var caption: String
    var createdAt: Date

    init(id: UUID = UUID(), maintenanceIssueId: UUID, imageData: Data?, caption: String = "", createdAt: Date = .now) {
        self.id = id
        self.maintenanceIssueId = maintenanceIssueId
        self.imageData = imageData
        self.caption = caption
        self.createdAt = createdAt
    }
}

@Model
final class Inspection {
    @Attribute(.unique) var id: UUID
    var propertyId: UUID
    var inspectionType: String
    var date: Date
    var notes: String
    var score: Double
    var createdAt: Date

    init(id: UUID = UUID(), propertyId: UUID, inspectionType: InspectionType, date: Date = .now, notes: String = "", score: Double = 100, createdAt: Date = .now) {
        self.id = id
        self.propertyId = propertyId
        self.inspectionType = inspectionType.rawValue
        self.date = date
        self.notes = notes
        self.score = score
        self.createdAt = createdAt
    }
}

@Model
final class InspectionChecklistItem {
    @Attribute(.unique) var id: UUID
    var inspectionId: UUID
    var title: String
    var passed: Bool
    var notes: String

    init(id: UUID = UUID(), inspectionId: UUID, title: String, passed: Bool = true, notes: String = "") {
        self.id = id
        self.inspectionId = inspectionId
        self.title = title
        self.passed = passed
        self.notes = notes
    }
}

@Model
final class RecurringMaintenanceTask {
    @Attribute(.unique) var id: UUID
    var propertyId: UUID
    var title: String
    var category: String
    var frequency: String
    var nextDueDate: Date
    var completed: Bool

    init(id: UUID = UUID(), propertyId: UUID, title: String, category: String, frequency: MaintenanceFrequency, nextDueDate: Date, completed: Bool = false) {
        self.id = id
        self.propertyId = propertyId
        self.title = title
        self.category = category
        self.frequency = frequency.rawValue
        self.nextDueDate = nextDueDate
        self.completed = completed
    }
}

@Model
final class RepairCostRecord {
    @Attribute(.unique) var id: UUID
    var maintenanceIssueId: UUID
    var contractorName: String
    var laborCost: Double
    var materialsCost: Double
    var repairDate: Date
    var paymentStatus: String

    var totalCost: Double { laborCost + materialsCost }

    init(id: UUID = UUID(), maintenanceIssueId: UUID, contractorName: String, laborCost: Double, materialsCost: Double, repairDate: Date = .now, paymentStatus: PaymentStatus = .pending) {
        self.id = id
        self.maintenanceIssueId = maintenanceIssueId
        self.contractorName = contractorName
        self.laborCost = laborCost
        self.materialsCost = materialsCost
        self.repairDate = repairDate
        self.paymentStatus = paymentStatus.rawValue
    }
}

@Model
final class MaintenanceReport {
    @Attribute(.unique) var id: UUID
    var propertyId: UUID
    var title: String
    var summary: String
    var pdfLocalURL: URL?
    var createdAt: Date

    init(id: UUID = UUID(), propertyId: UUID, title: String, summary: String, pdfLocalURL: URL? = nil, createdAt: Date = .now) {
        self.id = id
        self.propertyId = propertyId
        self.title = title
        self.summary = summary
        self.pdfLocalURL = pdfLocalURL
        self.createdAt = createdAt
    }
}

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var plan: String
    var isActive: Bool
    var renewsAt: Date?

    init(id: UUID = UUID(), plan: SubscriptionPlan = .free, isActive: Bool = false, renewsAt: Date? = nil) {
        self.id = id
        self.plan = plan.rawValue
        self.isActive = isActive
        self.renewsAt = renewsAt
    }
}
