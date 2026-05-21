# FixPilot App Store Connect Submission Pack

Prepared for App Store Connect entry. This is not legal advice; confirm privacy, terms, and export compliance with the account holder or counsel before release.

## App Record

- Platform: iOS
- Name: FixPilot AI Maintenance
- Apple ID: `6771884260`
- Primary language: English (U.K.) or English (U.S.)
- Bundle ID: `com.fixpilot.app`
- SKU: `fixpilot-ios-001`
- User access: Full access
- Category: Business
- Secondary category: Productivity
- Content rights: The app does not contain, show, or access third-party content.
- Made for Kids: No

## Version Information

- Version: `1.0`
- Copyright: `2026 FixPilot`
- Promotional text:
  `AI-powered property maintenance, repair tracking, inspections, reminders, repair costs, and professional PDF reports for landlords and property teams.`
- Description:
  `FixPilot AI Maintenance helps landlords, property managers, Airbnb hosts, facilities teams, contractors, and building managers stay on top of property maintenance. Track repair requests, prioritize urgent issues, organize inspections, schedule recurring maintenance, document repairs with photos, monitor repair spend, and generate professional maintenance reports.`

  `The app is offline-friendly with local SwiftData storage and includes a cautious AI maintenance assistant in mock mode by default. AI suggestions are informational only and are not engineering advice, structural certification, legal advice, or a substitute for a qualified professional inspection.`

  `Key features:`
  `• Track maintenance issues by property, room, category, severity, and status`
  `• Add photos and notes to repair records`
  `• Run move-in, move-out, routine, safety, seasonal, and Airbnb turnover inspections`
  `• Schedule recurring maintenance such as boiler servicing, HVAC checks, smoke detector checks, gutter cleaning, pest control, roof inspections, and appliance servicing`
  `• Record labour, material costs, contractor names, payment status, and repair dates`
  `• View maintenance analytics and repair spend charts`
  `• Generate and share PDF maintenance reports`
  `• Manage subscriptions with Free, Pro, and Business plan scaffolding`

- Keywords:
  `property maintenance, landlord, property manager, repairs, inspections, Airbnb, facilities management, contractor, maintenance reports, recurring maintenance`
- Support URL:
  `https://github.com/lanray07/FixPilot`
- Marketing URL:
  `https://github.com/lanray07/FixPilot`
- Privacy Policy URL:
  `https://github.com/lanray07/FixPilot/blob/main/PRIVACY.md`

## Review Information

- Sign-in required: No
- Demo account: Not required
- Review notes:
  `FixPilot stores maintenance, property, inspection, report, and repair cost data locally on device using SwiftData. Mock AI mode is enabled by default and does not require an external AI provider. The remote AI endpoint is a placeholder and no API keys are stored in the app. Camera and photo library permissions are used only so users can attach photo evidence to maintenance issues. Local notifications are used for recurring maintenance reminders.`

## App Privacy

Recommended privacy label for the current shipped scaffold, assuming no production backend, analytics, crash reporting SDK, advertising SDK, user account system, or remote AI processing is enabled:

- Data collected: No
- Tracking: No
- Data linked to user: No
- Data used to track users: No

Important: If you enable the remote AI endpoint, cloud sync, accounts, analytics, crash reporting, support chat, or server-side report storage, update App Privacy before submission. Remote AI processing may require disclosing User Content such as photos, notes, property details, and issue descriptions depending on what is transmitted and retained.

## Privacy Questionnaire Notes

- Contact Info: Not collected
- Health and Fitness: Not collected
- Financial Info: Not collected
- Location: Not collected
- Sensitive Info: Not collected
- Contacts: Not collected
- User Content: Not collected by developer in the local-only build; user-created issue notes/photos remain on device unless the user shares/export them.
- Browsing History: Not collected
- Search History: Not collected
- Identifiers: Not collected
- Purchases: App Store subscription transaction data is handled by Apple/StoreKit. Do not add third-party subscription analytics unless disclosed.
- Usage Data: Not collected
- Diagnostics: Not collected unless you later add crash/analytics tooling.

Sources:
- Apple App Privacy Details: https://developer.apple.com/app-store/app-privacy-details/
- Apple Manage App Privacy: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy

## Export Compliance

Current app uses platform networking and StoreKit only, with no custom cryptography. Recommended App Store Connect answer, subject to your legal confirmation:

- Uses encryption: Yes, standard Apple operating system encryption/HTTPS may be used.
- Uses non-exempt encryption: No.

The project includes `ITSAppUsesNonExemptEncryption = false` in `Info.plist` to help Xcode/App Store Connect with export compliance.

Source:
- Apple export compliance help: https://help.apple.com/xcode/mac/current/en.lproj/dev0dc15d044.html

## Age Rating

Suggested responses:

- Unrestricted web access: No
- Gambling/contests: No
- Medical/treatment information: No
- Alcohol/tobacco/drugs references: None
- Sexual content/nudity: None
- Violence/horror/profanity: None
- User-generated content: No public user-generated content
- Age rating target: 4+

## Subscriptions

Subscription group:
- Reference name: `FixPilot Subscriptions`

Products:

1. Pro Monthly
- Product ID: `fixpilot.pro.monthly`
- Reference name: `FixPilot Pro Monthly`
- Type: Auto-renewable subscription
- Duration: 1 month
- Price placeholder: `£19.99`
- Display name: `FixPilot Pro Monthly`
- Description: `AI maintenance assistant, PDF exports, recurring reminders, analytics, and expanded property maintenance tracking.`

2. Pro Yearly
- Product ID: `fixpilot.pro.yearly`
- Reference name: `FixPilot Pro Yearly`
- Type: Auto-renewable subscription
- Duration: 1 year
- Price placeholder: `£149.99`
- Display name: `FixPilot Pro Yearly`
- Description: `Annual access to Pro maintenance workflows, AI assistance, PDF exports, recurring reminders, analytics, and expanded tracking.`

3. Business Monthly
- Product ID: `fixpilot.business.monthly`
- Reference name: `FixPilot Business Monthly`
- Type: Auto-renewable subscription
- Duration: 1 month
- Price placeholder: `£79.99`
- Display name: `FixPilot Business Monthly`
- Description: `Unlimited properties, advanced reporting, custom branding placeholders, and contractor/team workflow placeholders.`

Pricing source:
- Apple pricing help: https://developer.apple.com/help/app-store-connect/manage-app-pricing/set-a-price

## App Review Risks To Resolve Before Submission

- Replace placeholder Privacy Policy, Terms, Support, and Marketing URLs with live pages.
- Add a real app icon and launch assets.
- Add App Store screenshots for required iPhone and optional iPad sizes.
- Confirm the bundle identifier belongs to your Apple Developer account.
- Create App Store Connect in-app purchases matching the product IDs in `SubscriptionService`.
- Add a StoreKit configuration file for local purchase testing if desired.
- Confirm whether remote AI will ship. If yes, replace `https://YOUR_BACKEND_URL.com/fixpilot-ai`, remove any user-facing broken toggle, and update privacy disclosures.
- Build and archive from Xcode on macOS, then upload with Xcode Organizer or Transporter.

## Manual App Store Connect Entry Steps

1. In Certificates, Identifiers & Profiles, register App ID `com.fixpilot.app`.
2. In App Store Connect, create a new iOS app named `FixPilot`.
3. Select bundle ID `com.fixpilot.app`.
4. Enter SKU `fixpilot-ios-001`.
5. Fill App Information, Pricing and Availability, App Privacy, Age Rating, and Review Information using this pack.
6. Create the subscription group and three auto-renewable subscription products.
7. Upload a build from Xcode.
8. Select the uploaded build in the `1.0` version page.
9. Add screenshots, app icon, support/privacy/marketing URLs, and submit for review.
