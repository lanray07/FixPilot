import Foundation
import StoreKit

@MainActor
final class SubscriptionStore: ObservableObject {
    @Published var currentPlan: SubscriptionPlan = .free
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let productIds = [
        "com.fixpilot.pro.monthly",
        "com.fixpilot.pro.yearly",
        "com.fixpilot.business.monthly"
    ]

    var hasProAccess: Bool { currentPlan == .pro || currentPlan == .business }
    var hasBusinessAccess: Bool { currentPlan == .business }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: productIds)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result, case .verified(let transaction) = verification {
                currentPlan = product.id.contains("business") ? .business : .pro
                await transaction.finish()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                currentPlan = transaction.productID.contains("business") ? .business : .pro
            }
        }
    }
}
