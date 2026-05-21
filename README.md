# FixPilot

FixPilot is a SwiftUI iOS app for property maintenance, repair tracking, inspections, recurring reminders, repair cost analytics, PDF reports, and cautious AI-assisted maintenance summaries.

## Build

Open `FixPilot.xcodeproj` in Xcode 16 or newer and run the `FixPilot` scheme on an iOS 17+ simulator or device.

The project uses:

- SwiftUI `NavigationStack` and `TabView`
- MVVM-style app and AI view models
- SwiftData local persistence
- StoreKit 2 subscription scaffolding
- PhotosPicker and camera capture
- Local notifications
- Swift Charts
- Native PDF generation and sharing

## AI mode

Mock AI is enabled by default in Settings. The remote AI service intentionally points to:

`https://YOUR_BACKEND_URL.com/fixpilot-ai`

Do not put API keys in the iOS app. Replace this placeholder with a secure backend endpoint that owns provider credentials and applies safety policy.

## StoreKit

Placeholder product identifiers are defined in `SubscriptionService`:

- `fixpilot.pro.monthly`
- `fixpilot.pro.yearly`
- `fixpilot.business.monthly`

Create matching App Store Connect products or add a StoreKit configuration file before production subscription testing.
