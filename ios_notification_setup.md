# iOS Notification Setup Instructions

## 1. Add Notification Sound Files

1. Create custom alarm sound files (`.aiff` format recommended for iOS)
2. Add them to your iOS project:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Right-click on `Runner` folder → `Add Files to "Runner"`
   - Select your sound files (e.g., `alarm_sound.aiff`)
   - Make sure "Copy items if needed" is checked
   - Select "Runner" target

## 2. Configure Info.plist

Add these entries to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>background-fetch</string>
    <string>background-processing</string>
    <string>remote-notification</string>
</array>

<key>NSUserNotificationAlertStyle</key>
<string>alert</string>
```

## 3. Create Notification Category (Optional)

For better alarm handling, add this to your `AppDelegate.swift`:

```swift
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Set up notification categories
        let alarmCategory = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

## 4. Update AppDelegate for Background Processing

Replace your `AppDelegate.swift` with enhanced version:

```swift
import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else {
                print("Notification permissions denied")
            }
        }
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Handle notification when app is in foreground
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .badge, .sound])
    }
    
    // Handle notification tap
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("Notification tapped: \(response.notification.request.content.title)")
        completionHandler()
    }
}
```

## 5. Capabilities Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select `Runner` project
3. Go to `Signing & Capabilities` tab
4. Click `+ Capability`
5. Add `Background Modes`
6. Check `Background fetch`, `Background processing`, and `Remote notifications`

## 6. Testing on iOS Simulator

1. Build and run on iOS Simulator
2. Grant notification permissions when prompted
3. Test with example functions from `NotificationExamples`
4. Note: Simulator may have limited notification support

## 7. Testing on Real Device

1. Connect your iOS device
2. Build and run on device
3. Grant notification permissions when prompted
4. Test alarm scheduling and notifications
5. Test with app in background and foreground

## 8. Troubleshooting

### Notifications not showing:
- Check if permissions are granted
- Verify sound files are properly added
- Check device notification settings
- Ensure app has background modes enabled

### Sound not playing:
- Verify sound file format (`.aiff` recommended)
- Check sound file name in code matches actual file
- Ensure device is not muted
- Check volume levels

### Background execution:
- Ensure background modes are enabled
- Test on real device (simulator limitations)
- Check iOS battery optimization settings

## 9. Additional Configuration

For production apps, consider:
- Adding proper error handling
- Implementing notification grouping
- Adding custom actions for notifications
- Setting up proper sound file management
- Handling timezone changes properly

## 10. Required Files Summary

- `lib/services/notification_service.dart` - Main notification service
- `lib/examples/notification_examples.dart` - Example usage
- `ios/Runner/Info.plist` - Updated with notification permissions
- `ios/Runner/AppDelegate.swift` - Enhanced notification handling
- Custom sound files in `ios/Runner/` directory
