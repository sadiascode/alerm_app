import Flutter
import UIKit
import UserNotifications

@main
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
