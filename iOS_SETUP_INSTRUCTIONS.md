# iOS Local Notifications Setup Guide

This guide will help you set up local notifications for your Flutter alarm app on iOS devices and simulators.

## 1. iOS Configuration Files

### Update Info.plist
Add the following permissions to your `ios/Runner/Info.plist` file:

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

### Update AppDelegate
Modify your `ios/Runner/AppDelegate.swift` file:

```swift
import UIKit
import Flutter
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 2. Add Sound Files (Optional)

### Add Custom Alarm Sound
1. Create an alarm sound file (`.aiff` format recommended for iOS)
2. Add it to your Xcode project: `ios/Runner/Assets.xcassets/`
3. Or place it directly in: `ios/Runner/alarm_sound.aiff`

### Update NotificationService
Make sure the sound file name matches in your NotificationService:
```dart
sound: 'alarm_sound.aiff', // in DarwinNotificationDetails
```

## 3. iOS Capabilities

### Enable Background Modes
1. Open your project in Xcode: `ios/Runner.xcworkspace`
2. Select your app target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability" and add "Background Modes"
5. Check:
   - Background fetch
   - Background processing
   - Remote notifications

### Enable Push Notifications
1. Click "+ Capability" and add "Push Notifications"
2. This is required even for local notifications on iOS

## 4. Testing on iOS Simulator

### Simulator Limitations
- iOS Simulator supports local notifications
- Sound may not play in some simulator versions
- Vibration is not available on simulator
- Background execution is limited

### Testing Steps
1. Build and run on simulator:
   ```bash
   flutter run -d ios
   ```

2. Grant notification permissions when prompted

3. Test notification scheduling:
   - Create an alarm
   - Check that notification appears at scheduled time
   - Test toggle on/off functionality

## 5. Testing on Real iOS Device

### Device Requirements
- iOS 10.0 or higher
- Physical device for full functionality testing

### Testing Steps
1. Connect your iOS device
2. Build and run:
   ```bash
   flutter run -d ios
   ```

3. Grant notification permissions when prompted

4. Test all features:
   - Alarm creation and scheduling
   - Notification sound and vibration
   - Background notifications
   - Toggle on/off functionality
   - Delete alarm functionality

## 6. Common Issues & Solutions

### Permissions Not Granted
- Ensure you're requesting permissions properly
- Check device Settings > Your App > Notifications
- Make sure "Allow Notifications" is enabled

### Notifications Not Appearing
- Check that background modes are enabled
- Verify app is not force-closed
- Test with different time intervals (e.g., 1 minute for testing)

### Sound Not Playing
- Verify sound file exists in correct location
- Check file format (`.aiff` recommended)
- Ensure device volume is up
- Check device "Do Not Disturb" settings

### Background Execution Issues
- Ensure background modes are properly configured
- Test on real device (simulator has limitations)
- Check device battery optimization settings

## 7. Debugging

### Enable Debug Logging
Add this to your NotificationService for debugging:
```dart
debugPrint('Notification scheduled: $notificationId at $scheduledTime');
```

### Check Notification Status
Use this method to check pending notifications:
```dart
final pending = await NotificationService().getPendingNotifications();
print('Pending notifications: ${pending.length}');
```

### Simulator Testing Tips
- Use short time intervals for testing (1-2 minutes)
- Test notification permission flow
- Verify notification scheduling works
- Test with app in background and foreground

## 8. Production Checklist

Before releasing to App Store:

- [ ] Test on multiple iOS devices
- [ ] Verify notification permissions flow
- [ ] Test background notification delivery
- [ ] Ensure sound files are included
- [ ] Test with different time zones
- [ ] Verify alarm persistence across app restarts
- [ ] Test with device in Do Not Disturb mode
- [ ] Check battery optimization impact

## 9. Additional Resources

- [Flutter Local Notifications Package](https://pub.dev/packages/flutter_local_notifications)
- [Apple Local Notifications Documentation](https://developer.apple.com/documentation/usernotifications)
- [iOS Background Execution Guide](https://developer.apple.com/documentation/uikit/app_and_environment/managing_your_app_s_life_cycle)

## 10. Quick Test Commands

### Test Notification Service
Add this test function to your app:
```dart
// Add this to any widget for testing
ElevatedButton(
  onPressed: () => NotificationService().showTestNotification(),
  child: Text('Test Notification'),
)
```

### Check Pending Alarms
```dart
// Check what alarms are scheduled
final pending = await NotificationService().getPendingNotifications();
for (final notification in pending) {
  print('ID: ${notification.id}, Title: ${notification.title}');
}
```

This setup ensures your alarm notifications work reliably on both iOS simulator and real devices while maintaining your existing UI design.
