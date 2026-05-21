import SwiftUI
import SwiftData

enum AppRoute: Hashable {
    case propertyEditor
    case issueEditor
    case inspectionEditor
    case maintenanceScheduler
    case reportGenerator
    case paywall
}

struct RootView: View {
    @EnvironmentObject private var app: AppViewModel

    var body: some View {
        Group {
            if app.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            PropertiesView()
                .tabItem { Label("Properties", systemImage: "building.2") }
            IssuesView()
                .tabItem { Label("Issues", systemImage: "wrench.adjustable") }
            InspectionsView()
                .tabItem { Label("Inspect", systemImage: "checklist") }
            ReportsCenterView()
                .tabItem { Label("Reports", systemImage: "doc.richtext") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(.teal)
    }
}
