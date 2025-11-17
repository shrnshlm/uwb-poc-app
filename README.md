# UWB POC App

A Flutter proof-of-concept application demonstrating Ultra-Wideband (UWB) technology on iOS devices using the NearbyInteraction framework.

## Features

- Check UWB support on device
- Start/stop UWB ranging sessions
- Measure distance to nearby UWB-enabled devices
- Display directional information (azimuth and elevation)

## Requirements

- iOS 14.0 or later
- iPhone 11 or later (UWB hardware required)
- Xcode 14.0 or later
- Flutter 3.0 or later

## Project Structure

```
uwb_poc_app/
├── lib/
│   └── main.dart              # Flutter UI and method channel implementation
├── ios/
│   ├── Runner/
│   │   ├── AppDelegate.swift  # iOS native UWB implementation
│   │   ├── Info.plist         # iOS permissions
│   │   └── Runner.entitlements # UWB entitlements
│   ├── Podfile                # CocoaPods dependencies
│   └── Runner.xcodeproj/      # Xcode project configuration
├── codemagic.yaml             # Codemagic CI/CD configuration
└── pubspec.yaml               # Flutter dependencies
```

## Local Development (if Flutter is installed)

1. Install dependencies:
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Deploying to Codemagic for iOS Build

### Step 1: Push to GitHub

1. Initialize a git repository in your project:
   ```bash
   cd uwb_poc_app
   git init
   git add .
   git commit -m "Initial commit: UWB POC app"
   ```

2. Create a new repository on your personal GitHub account

3. Push the code:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/uwb_poc_app.git
   git branch -M main
   git push -u origin main
   ```

### Step 2: Configure Codemagic

1. Go to [codemagic.io](https://codemagic.io) and sign in with your GitHub account

2. Click "Add application" and select your `uwb_poc_app` repository

3. Codemagic will automatically detect the `codemagic.yaml` file

4. Configure iOS code signing:
   - Go to "Teams" > "Code signing identities"
   - Add your Apple Developer certificate and provisioning profile
   - Or use Codemagic's automatic code signing with your Apple Developer credentials

5. Update the `codemagic.yaml` file with your details:
   - Change `com.yourcompany.uwbpocapp` to your bundle identifier
   - Update the email address for build notifications
   - Add your App Store Connect credentials (if deploying to TestFlight)

### Step 3: Update Bundle Identifier

Before building, update the bundle identifier in these files:

1. [ios/Runner.xcodeproj/project.pbxproj](ios/Runner.xcodeproj/project.pbxproj) - Line with `PRODUCT_BUNDLE_IDENTIFIER`
2. [codemagic.yaml](codemagic.yaml) - Line with `bundle_identifier`

Replace `com.yourcompany.uwbpocapp` with your actual bundle identifier (e.g., `com.yourdomain.uwbpoc`)

### Step 4: Apple Developer Setup

1. Log in to [Apple Developer](https://developer.apple.com)

2. Create an App ID with the NearbyInteraction capability:
   - Go to "Certificates, Identifiers & Profiles"
   - Click "Identifiers" > "+"
   - Select "App IDs" and continue
   - Enter your bundle identifier
   - Under "Capabilities", enable "NearbyInteraction"
   - Register the App ID

3. Create a provisioning profile for your App ID

4. Download and add to Codemagic or use automatic signing

### Step 5: Build and Deploy

1. In Codemagic, click "Start new build"

2. Select the `ios-workflow` workflow

3. The build will:
   - Install Flutter dependencies
   - Install iOS CocoaPods
   - Build the iOS app
   - Generate an IPA file

4. Download the IPA file from build artifacts

5. Install on your iPhone:
   - Upload to TestFlight (if configured)
   - Or install directly using tools like Apple Configurator or Xcode

## Important Notes

### UWB Requirements

- **Hardware**: UWB only works on iPhone 11 and later models with the U1 chip
- **iOS Version**: Requires iOS 14.0 or later
- **Permissions**: User must grant NearbyInteraction permission when prompted

### Token Exchange

This POC demonstrates the UWB framework structure. In a production app, you would need to:
1. Use another communication method (BLE, WiFi Direct, etc.) to exchange discovery tokens between devices
2. Implement proper token sharing logic
3. Handle peer discovery and session management

### Testing

To test UWB functionality, you need:
- Two UWB-capable iPhones (iPhone 11 or later)
- Both devices running the app
- Proper token exchange implementation (not included in this POC)

## Troubleshooting

### Build Fails on Codemagic

- Check that bundle identifier matches across all configuration files
- Verify iOS code signing is properly configured
- Ensure NearbyInteraction capability is enabled in Apple Developer portal

### App Crashes on Launch

- Verify Info.plist includes NSNearbyInteractionUsageDescription
- Check that Runner.entitlements includes com.apple.developer.nearby-interaction
- Ensure deployment target is iOS 14.0 or later

### "UWB Not Supported" Message

- Verify device is iPhone 11 or later
- Check iOS version is 14.0 or higher
- Ensure the app has proper entitlements

## License

This is a proof-of-concept application for educational purposes.

## Resources

- [Apple NearbyInteraction Framework](https://developer.apple.com/documentation/nearbyinteraction)
- [Flutter Platform Channels](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [Codemagic Documentation](https://docs.codemagic.io/)
