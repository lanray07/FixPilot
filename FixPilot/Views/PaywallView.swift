import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var subscription: SubscriptionStore
    @Environment(\.openURL) private var openURL

    private let privacyURL = URL(string: "https://github.com/lanray07/FixPilot/blob/main/PRIVACY.md")!
    private let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

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

                PlanCard(title: "Free", price: "$0", duration: "No subscription", features: ["1 property", "10 maintenance issues", "Basic reports", "FixPilot branding"], isCurrent: subscription.currentPlan == .free)
                PlanCard(title: "Pro Monthly", price: "$19.99", duration: "Renews monthly", features: ["Up to 10 properties", "Unlimited maintenance tracking", "AI assistant", "PDF exports", "Recurring reminders", "Analytics dashboard"], isCurrent: subscription.currentPlan == .pro)
                PlanCard(title: "Pro Yearly", price: "$149.99", duration: "Renews yearly", features: ["Up to 10 properties", "Unlimited maintenance tracking", "AI assistant", "PDF exports", "Recurring reminders", "Analytics dashboard"], isCurrent: subscription.currentPlan == .pro)
                PlanCard(title: "Business Monthly", price: "$79.99", duration: "Renews monthly", features: ["Unlimited properties", "Team workflow placeholder", "Custom branding", "Advanced reporting", "Contractor workflow placeholder"], isCurrent: subscription.currentPlan == .business)

                if subscription.isLoading {
                    ProgressView("Loading products...")
                } else if subscription.products.isEmpty {
                    Text("Subscription prices are shown in USD above and may be localized by the App Store before purchase.")
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

                VStack(alignment: .leading, spacing: 10) {
                    Text("Subscription Terms")
                        .font(.headline)
                    Text("Payment is charged to your Apple ID at purchase confirmation. Subscriptions renew automatically unless canceled at least 24 hours before the end of the current period. You can manage or cancel subscriptions in your App Store account settings.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    HStack {
                        Button("Privacy Policy") { openURL(privacyURL) }
                        Button("Terms of Use (EULA)") { openURL(termsURL) }
                    }
                    .font(.footnote.weight(.semibold))
                }
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
    let duration: String
    let features: [String]
    let isCurrent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title).font(.title3.weight(.bold))
                    Text("\(price) - \(duration)").foregroundStyle(.secondary)
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
