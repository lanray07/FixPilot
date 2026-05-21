import Foundation
import UIKit

final class PDFReportService {
    func generate(property: Property, issues: [MaintenanceIssue], inspections: [Inspection], costs: [RepairCostRecord], summary: String) throws -> URL {
        let fileName = "\(property.name.replacingOccurrences(of: " ", with: "-"))-maintenance-report.pdf"
        let url = FileManager.default.temporaryDirectory.appending(path: fileName)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        try renderer.writePDF(to: url) { context in
            context.beginPage()
            var y: CGFloat = 44
            y = draw("FixPilot Maintenance Report", at: y, font: .boldSystemFont(ofSize: 24), pageRect: pageRect)
            y = draw(property.name, at: y + 12, font: .boldSystemFont(ofSize: 18), pageRect: pageRect)
            y = draw(property.address, at: y + 6, font: .systemFont(ofSize: 12), pageRect: pageRect)
            y = draw("Property type: \(property.propertyType) | Rooms: \(property.roomCount)", at: y + 10, font: .systemFont(ofSize: 12), pageRect: pageRect)
            y = draw("Summary", at: y + 24, font: .boldSystemFont(ofSize: 16), pageRect: pageRect)
            y = draw(summary, at: y + 6, font: .systemFont(ofSize: 12), pageRect: pageRect)

            y = draw("Issues", at: y + 20, font: .boldSystemFont(ofSize: 16), pageRect: pageRect)
            for issue in issues.prefix(12) {
                y = draw("• \(issue.title) | \(issue.category) | \(issue.severity) | \(issue.status)", at: y + 4, font: .systemFont(ofSize: 11), pageRect: pageRect)
            }

            y = draw("Inspections", at: y + 20, font: .boldSystemFont(ofSize: 16), pageRect: pageRect)
            for inspection in inspections.prefix(8) {
                y = draw("• \(inspection.inspectionType) | Score \(Int(inspection.score)) | \(inspection.date.formatted(date: .abbreviated, time: .omitted))", at: y + 4, font: .systemFont(ofSize: 11), pageRect: pageRect)
            }

            let spend = costs.reduce(0.0) { $0 + $1.totalCost }
            y = draw("Repair spend: \(spend.currency())", at: y + 20, font: .boldSystemFont(ofSize: 14), pageRect: pageRect)
            _ = draw("Disclaimer: AI suggestions are informational only. Not engineering advice, structural certification, legal advice, or a substitute for qualified professional inspection. Urgent safety issues should be checked immediately.", at: y + 22, font: .systemFont(ofSize: 10), pageRect: pageRect)
        }
        return url
    }

    private func draw(_ text: String, at y: CGFloat, font: UIFont, pageRect: CGRect) -> CGFloat {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: paragraph, .foregroundColor: UIColor.label]
        let rect = CGRect(x: 44, y: y, width: pageRect.width - 88, height: pageRect.height - y - 44)
        let height = text.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil).height
        text.draw(with: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: height + 4), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
        return y + height + 4
    }
}
