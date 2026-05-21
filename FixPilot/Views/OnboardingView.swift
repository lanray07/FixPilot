import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var app: AppViewModel
    @State private var userType = UserType.landlord
    @State private var propertyCount = "1"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.teal)
                        Text("FixPilot")
                            .font(.largeTitle.weight(.bold))
                        Text("Property maintenance, inspections, repairs, reminders, reports, and cautious AI assistance in one field-ready app.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your role").font(.headline)
                        Picker("User type", selection: $userType) {
                            ForEach(UserType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.inline)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Property count").font(.headline)
                        Picker("Property count", selection: $propertyCount) {
                            Text("1").tag("1")
                            Text("2-10").tag("2-10")
                            Text("11-50").tag("11-50")
                            Text("50+").tag("50+")
                        }
                        .pickerStyle(.segmented)
                    }

                    DisclaimerBanner()

                    Text(FixPilotDisclaimer.full)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button {
                        app.selectedUserType = userType.rawValue
                        app.selectedPropertyCount = propertyCount
                        app.hasCompletedOnboarding = true
                    } label: {
                        Label("Start managing maintenance", systemImage: "arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
            }
        }
    }
}
