import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

// Future<void> sendNotificationToAllDevices() async {
//   try {
//     // Retrieve all documents from the 'devices' collection
//     QuerySnapshot devicesSnapshot =
//         await FirebaseFirestore.instance.collection('devices').get();

//     // Extract FCM tokens from the documents
//     List<String> tokens = devicesSnapshot.docs
//         .map((doc) => doc.data()['fcmToken'].toString())
//         .toList();

//     // Send a notification to each device using the FCM tokens
//     // await _sendNotification(
//     //     tokens, 'Your Notification Title', 'Your Notification Body');

//     print('Notification sent to all devices successfully.');
//   } catch (e) {
//     print('Error sending notification: $e');
//   }
// }

// Future<void> _sendNotification(
//     List<String> tokens, String title, String body) async {
//   try {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     final List<Message> messages = tokens.map((token) {
//       return Message(
//         data: {
//           'title': title,
//           'body': body,
//         },
//         token: token,
//       );
//     }).toList();

//     final MulticastMessage multicastMessage = MulticastMessage(
//       messages: messages,
//       data: {
//         'title': title,
//         'body': body,
//       },
//     );

//     await messaging.sendMulticast(multicastMessage);
//   } catch (e) {
//     print('Error sending notification to devices: $e');
//   }
// }

Future<void> sendNotificationToDevice(
    String token, String title, String body) async {
  try {
    String serverKey =
        "AAAAn9lTa_8:APA91bF6gQj2l6K6GHyeb1E0FM9rx6AnF1sdU_2gXVa-RA-j_GzjNp_pcJC3vMoXy3TRFfXCn1l5is-oWFrfUVTlOd1mo4TYH9vxNmgFbk6qYP3jHVCKzVy-Oq2FJdrKDRJoeEsNKKWz"; // Replace with your Firebase project's server key

    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/fir-c987f/messages:send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode({
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent to device with token $token successfully.');
    } else {
      print(
          'Error sending notification to device. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending notification to device: $e');
  }
}
