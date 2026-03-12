import Flutter
import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Configure Firebase
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    
    // Set up notification delegate BEFORE requesting permissions
    UNUserNotificationCenter.current().delegate = self
    
    // Request notification permissions with proper options for Firebase
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .providesAppNotificationSettings]) { granted, error in
      if granted {
        print("Notification permissions granted")
        // Register for remote notifications AFTER permission is granted
        DispatchQueue.main.async {
          application.registerForRemoteNotifications()
        }
      } else {
        print("Notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
      }
    }
    
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
  
  // Handle remote notification registration success
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("APNS device token received: \(deviceToken.hexEncodedString())")
    // Let Firebase handle the device token
    Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
  }
  
  // Handle remote notification registration failure
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
  }
  
  // Handle silent remote notifications
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("Received remote notification in background: \(userInfo)")
    // Let Firebase handle the notification
    Messaging.messaging().appDidReceiveMessage(userInfo)
    completionHandler(.newData)
  }
  // MARK: - MessagingDelegate
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(fcmToken ?? "nil")")
  }
}


// Extension to convert Data to hex string
extension Data {
  func hexEncodedString() -> String {
    return map { String(format: "%02hhx", $0) }.joined()
  }
}
