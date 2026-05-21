import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var subscription: SubscriptionStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.teal)
                    Text("Upgrade FixPilot")
                        .font(.largeTitle.weight(.bold))
                    Text("Unlock AI maintenance assistance, PDF exports, recurring reminders, analytics, property history, repair spend tracking, branding, and multi-property workflows.")
                        .foregroundStyle(.secondary)
                }

                PlanCard(title: "Free", price: "£0", features: ["1 property", "10 maintenance issues", "Basic reports", "FixPilot branding"], isCurrent: subscription.currentPlan == .free)
                PlanCard(title: "Pro", price: "£19.99/mo or £149.99/yr", features: ["Up to 10 properties", "Unlimited maintenance tracking", "AI assistant", "PDF exports", "Recurring reminders", "Analytics dashboard"], isCurrent: subscription.currentPlan == .pro)
                PlanCard(title: "Business", price: "£79.99/mo", features: ["Unlimited properties", "Team workflow placeholder", "Custom branding", "Advanced reporting", "Contractor workflow placeholder"], isCurrent: subscription.currentPlan == .business)

                if subscription.isLoading {
                    ProgressView("Loading products...")
                } else if subscription.products.isEmpty {
                    Text("StoreKit products are scaffolded with placeholder identifiers. Add matching products in App Store Connect or a StoreKit configuration file.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(subscription.products) { product in
                        Button {
                            Task { await subscription.purchase(product) }
                        } label: {
                            Text("Choose \(product.displayName) - \(product.displayPrice)")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                Button("Restore purchases") {
                    Task { await subscription.restorePurchases() }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle("Plans")
        .task { await subscription.loadProducts() }
    }
}

private struct PlanCard: View {
    let title: String
    let price: String
    let features: [String]
    let isCurrent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title).font(.title3.weight(.bold))
                    Text(price).foregroundStyle(.secondary)
                }
                Spacer()
                if isCurrent {
                    Text("Current")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.teal.opacity(0.12), in: Capsule())
                }
            }
            ForEach(features, id: \.self) { feature in
                Label(feature, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.primary)
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isCurrent ? Color.teal : Color.secondary.opacity(0.2), lineWidth: isCurrent ? 2 : 1))
    }
}
