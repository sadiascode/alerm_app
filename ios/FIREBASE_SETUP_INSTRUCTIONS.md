# iOS Configuration Instructions for Firebase Messaging

## Required Xcode Capabilities

1. **Push Notifications**
   - Open ios/Runner.xcworkspace in Xcode
   - Select Runner target
   - Go to "Signing & Capabilities" tab
   - Click "+ Capability"
   - Add "Push Notifications"

2. **Background Modes** (Already configured in Info.plist)
   - Background fetch
   - Background processing  
   - Remote notifications

## Firebase Console Setup

1. Go to Firebase Console (https://console.firebase.google.com)
2. Select your project
3. Go to Project Settings > Cloud Messaging
4. Upload your APNs authentication key (.p8 file)
5. Enable "APNs Authentication Key"
6. Add your Bundle ID (com.yourcompany.alerm)

## APNs Key Setup

1. Go to Apple Developer Portal (https://developer.apple.com)
2. Select "Certificates, Identifiers & Profiles"
3. Go to "Keys"
4. Create a new Key
5. Enable "Apple Push Notifications service (APNs)"
6. Download the .p8 file
7. Upload to Firebase Console

## Testing Steps

1. Build on real iOS device (not simulator)
2. Grant notification permissions when prompted
3. Check console logs for:
   - "Notification permissions granted"
   - "APNS device token received"
   - "FCM Token obtained successfully"

## Common Issues

- **Simulator**: Push notifications don't work on iOS simulator
- **APNs Key**: Must use .p8 key, not certificate
- **Bundle ID**: Must match exactly between Xcode and Firebase
- **Team**: Apple Developer Team must match APNs key
