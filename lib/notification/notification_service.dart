import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  bool _isInitialized = false;
  String? _cachedFCMToken;

  Future<void> initFCM() async {
    if (_isInitialized) return;

    try {
      debugPrint('Starting Firebase Messaging initialization...');
      
      // Set up message handlers FIRST - before any token operations
      _setupMessageHandlers();
      
      // Request permissions (non-blocking for app startup)
      _requestPermissions().catchError((e) {
        debugPrint('Permission request failed: $e');
      });
      
      // Initialize token handling with proper iOS APNS flow
      await _initializeTokenHandling();
      
      _isInitialized = true;
      debugPrint('Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
      // Don't rethrow - allow app to continue
    }
  }

  Future<void> _initializeTokenHandling() async {
    if (Platform.isIOS) {
      await _initializeIOSTokenHandling();
    } else {
      await _getFCMTokenSafely();
    }
  }

  Future<void> _initializeIOSTokenHandling() async {
    // For iOS, we need to wait for the APNS token to be available
    // This happens after the app registers for remote notifications
    
    debugPrint('Initializing iOS token handling...');
    
    // Set up token refresh listener first
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint('FCM token refreshed: $token');
      _cachedFCMToken = token;
    });
    
    // Try to get token with proper APNS handling
    await _getFCMTokenWithAPNSRetry();
  }

  Future<void> _getFCMTokenWithAPNSRetry() async {
    const maxAttempts = 10;
    const baseDelay = Duration(seconds: 1);
    const maxDelay = Duration(seconds: 5);
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        debugPrint('Token attempt ${attempt + 1}/$maxAttempts');
        
        // Check APNS token availability first
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          debugPrint('APNS token available, getting FCM token...');
          
          final fcmToken = await _firebaseMessaging.getToken();
          if (fcmToken != null) {
            _cachedFCMToken = fcmToken;
            debugPrint('FCM Token obtained successfully: $fcmToken');
            return;
          }
        } else {
          debugPrint('APNS token not yet available');
        }
        
        // Exponential backoff with jitter
        if (attempt < maxAttempts - 1) {
          final delay = _calculateBackoffDelay(attempt, baseDelay, maxDelay);
          debugPrint('Waiting ${delay.inMilliseconds}ms before retry...');
          await Future.delayed(delay);
        }
        
      } catch (e) {
        debugPrint('Token attempt ${attempt + 1} failed: $e');
        
        if (attempt < maxAttempts - 1) {
          final delay = _calculateBackoffDelay(attempt, baseDelay, maxDelay);
          await Future.delayed(delay);
        }
      }
    }
    
    debugPrint('Token initialization completed after $maxAttempts attempts');
    debugPrint('Note: FCM functionality may be limited without APNS token');
  }

  Duration _calculateBackoffDelay(int attempt, Duration baseDelay, Duration maxDelay) {
    final exponent = (attempt / 2).floor();
    final exponentialDelay = baseDelay * (1 << exponent);
    final jitter = Duration(milliseconds: (exponentialDelay.inMilliseconds * 0.1).round());
    final totalDelay = exponentialDelay + jitter;
    return totalDelay > maxDelay ? maxDelay : totalDelay;
  }

  Future<NotificationSettings> _requestPermissions() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }
      
      return settings;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      rethrow;
    }
  }

  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Message received in foreground: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Handle messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened app: ${message.notification?.title}');
      _handleMessageOpenedApp(message);
    });

    // Handle initial message (app opened from terminated state)
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state via notification: ${message.notification?.title}');
        _handleMessageOpenedApp(message);
      }
    }).catchError((e) {
      debugPrint('Error getting initial message: $e');
    });
  }

  Future<void> _getFCMTokenSafely() async {
    try {
      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        _cachedFCMToken = fcmToken;
        debugPrint("FCM Token : $fcmToken");
      } else {
        debugPrint("FCM Token is null - will retry later");
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      // Don't rethrow - token can be retrieved later
    }
  }

  // Public method to get current FCM token
  String? get currentFCMToken => _cachedFCMToken;

  // Public method to retry getting FCM token
  Future<String?> retryGetFCMToken() async {
    if (Platform.isIOS) {
      await _getFCMTokenWithAPNSRetry();
    } else {
      await _getFCMTokenSafely();
    }
    return _cachedFCMToken;
  }

  /// Returns the cached token if available, otherwise initiates retrieval.
  Future<String?> getFCMToken() async {
    if (_cachedFCMToken != null) return _cachedFCMToken;
    return await retryGetFCMToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification for FCM message when app is in foreground
    // This ensures user sees the notification even when app is open
    debugPrint('Showing in-app notification for foreground message');
    // You can show an in-app dialog, banner, or local notification here
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Navigate to appropriate screen based on message data
    debugPrint('Message data: ${message.data}');
  }
}