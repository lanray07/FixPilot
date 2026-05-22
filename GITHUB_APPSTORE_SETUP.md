# GitHub Xcode and App Store Upload Setup

The repository includes two workflows:

- `.github/workflows/ios-build.yml`: builds the app for iOS Simulator on every push.
- `.github/workflows/appstore-upload.yml`: manual archive/export/upload to App Store Connect.

## Required GitHub Secrets

Add these in GitHub: `Settings` -> `Secrets and variables` -> `Actions`.

### App Store Connect API

- `APPLE_TEAM_ID`: Apple Developer Team ID.
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API key ID.
- `APP_STORE_CONNECT_API_ISSUER_ID`: App Store Connect issuer ID.
- `APP_STORE_CONNECT_API_PRIVATE_KEY`: Full contents of the `.p8` private key.

Create this in App Store Connect: `Users and Access` -> `Integrations` -> `App Store Connect API`.

### iOS Signing

The upload workflow uses Xcode automatic signing with the App Store Connect API key. No `.p12` certificate or `.mobileprovision` profile secret is required in GitHub.

## Manual Run

1. Push to `main`.
2. Open GitHub Actions.
3. Run `App Store Archive Upload`, or push a tag named `appstore-build-<number>`.
4. Enter a build number higher than the last uploaded build when using the manual workflow button. Tag-triggered runs use the GitHub run number.

The workflow uploads the `.ipa` to App Store Connect for app ID `6771884260` / bundle ID `com.fixpilot.app`.

## Notes

- The app record already exists in App Store Connect as `FixPilot AI Maintenance`.
- The Apple Developer Team ID is `5ZP6GV85J6`.
- Do not commit certificates, provisioning profiles, or API keys to the repository.
