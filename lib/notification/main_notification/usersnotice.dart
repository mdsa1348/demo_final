import 'dart:io';

import 'package:demo/ThemeSwitch.dart';
import 'package:demo/notification/main_notification/adminnoticeDetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

class Notice {
  final String title;
  final String description;
  final String imageUrl;

  Notice({required this.title, required this.description, this.imageUrl = ''});
}

class userNoticeBoard extends StatefulWidget {
  @override
  _userNoticeBoardState createState() => _userNoticeBoardState();
}

class _userNoticeBoardState extends State<userNoticeBoard> {
  List<Notice> notices = [];
  late List<DocumentSnapshot> localDocuments;

  CollectionReference noticesCollection =
      FirebaseFirestore.instance.collection('notices');

  FirebaseStorage storage = FirebaseStorage.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Fetch data only if there is a successful internet connection
    _fetchData();
  }

  void subscribeToNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic('user_notifications');
  }

  Future<void> _fetchData() async {
    try {
      bool isConnected = await _isConnected();

      if (isConnected) {
        QuerySnapshot noticesSnapshot = await noticesCollection.get();

        setState(() {
          notices = noticesSnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Notice(
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              imageUrl: data['imageUrl'] ?? '',
            );
          }).toList();
        });
      } else {
        // If there is no internet connection, do nothing
        print('No internet connection available.');
      }
    } catch (error) {
      print('Error fetching data: $error');
      // Handle the error accordingly (show a message, log it, etc.)
    }
  }

  Future<bool> _isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> showNotification() async {
    var android = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      importance: Importance.max,
      priority: Priority.high,
      // Make sure to replace 'your_small_icon_name' with the actual name of your small icon in the 'drawable' folder.
      icon: '@mipmap/ic_launcher',
    );

    var platform = NotificationDetails(android: android);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notification Title',
      'Notification Body',
      platform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Admins Notice Board'),
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[700] // Dark theme background color
                : Colors.blue,
          ),
          body: Container(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900]
                : Colors.white,
            child: Column(
              children: [
                if (notices.isNotEmpty) // Only display if there are notices
                  Expanded(
                    child: ListView.builder(
                      itemCount: notices.length,
                      itemBuilder: (context, index) {
                        Notice notice = notices[index];

                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(notice.title),
                            subtitle: Text(
                              notice.description,
                              maxLines: 4,
                            ),
                            leading: notice.imageUrl.isNotEmpty
                                ? Image.network(notice.imageUrl)
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoticeDetail(
                                    title: notice.title,
                                    description: notice.description,
                                    imageUrl: notice.imageUrl,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                if (notices.isEmpty && notices.isNotEmpty)
                  Center(
                    child: Text('No data available'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
