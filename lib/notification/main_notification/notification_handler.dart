import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );

    await _getToken();

    // Set up the foreground message handler
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

    // Set up the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('Firebase Token: $token');

      // Check if the user is authenticated
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Get the current user's ID
        String currentUserUid = currentUser.uid;

        // Update the FCM token in Firestore
        await FirebaseFirestore.instance
            .collection('devices')
            .doc(currentUserUid)
            .set({'fcmToken': token});

        print('FCM token successfully updated in Firestore.');
      } else {
        print('Error: Current user not found. FCM token not updated.');
      }
    } catch (e) {
      print('Error getting Firebase token: $e');
    }
  }

  // Foreground message handler
  Future<void> _firebaseMessagingForegroundHandler(
      RemoteMessage message) async {
    print("Foreground Message Received:");
    print("ID: ${message.messageId}");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");

    // Handle the foreground message here
    await _displayNotification(
        message.notification?.title, message.notification?.body);
  }

  Future<void> _displayNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title ?? '', // Title of the notification
      body ?? '', // Body of the notification
      platformChannelSpecifics,
    );
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Background Message Received:");
    print("ID: ${message.messageId}");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");

    // Handle the background message here
  }
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Replace 'app_icon' with your app's icon name
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}
