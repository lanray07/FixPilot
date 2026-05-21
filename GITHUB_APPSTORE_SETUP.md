# GitHub Xcode and App Store Upload Setup

The repository includes two workflows:

- `.github/workflows/ios-build.yml`: builds the app for iOS Simulator on every push.
- `.github/workflows/appstore-upload.yml`: manual archive/export/upload to App Store Connect.

## Required GitHub Secrets

Add these in GitHub: `Settings` -> `Secrets and variables` -> `Actions`.

### App Store Connect API

- `ASC_KEY_ID`: App Store Connect API key ID.
- `ASC_ISSUER_ID`: App Store Connect issuer ID.
- `ASC_API_KEY_P8`: Full contents of the `.p8` private key.

Create this in App Store Connect: `Users and Access` -> `Integrations` -> `App Store Connect API`.

### iOS Signing

- `IOS_DISTRIBUTION_CERTIFICATE_BASE64`: Base64-encoded Apple Distribution `.p12` certificate.
- `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`: Password for the `.p12`.
- `IOS_APPSTORE_PROFILE_BASE64`: Base64-encoded App Store provisioning profile for `com.fixpilot.app`.
- `KEYCHAIN_PASSWORD`: Any strong temporary password used by the workflow keychain.

On macOS, encode files like this:

```bash
base64 -i distribution.p12 | pbcopy
base64 -i FixPilot_AppStore.mobileprovision | pbcopy
```

## Manual Run

1. Push to `main`.
2. Open GitHub Actions.
3. Run `App Store Archive Upload`.
4. Enter a build number higher than the last uploaded build.

The workflow uploads the `.ipa` to App Store Connect for app ID `6771884260` / bundle ID `com.fixpilot.app`.

## Notes

- The app record already exists in App Store Connect as `FixPilot AI Maintenance`.
- The Apple Developer Team ID is `5ZP6GV85J6`.
- Do not commit certificates, provisioning profiles, or API keys to the repository.
