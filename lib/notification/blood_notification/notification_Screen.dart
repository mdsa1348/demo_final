import 'package:demo/medical/users/User_payment_page.dart';
import 'package:demo/notification/blood_notification/important.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? currentUser; // Declare currentUser variable
  String? currentUserName;
  bool isUserNameFetched = false;

  Set<String> facedPairs = Set<String>(); // Add this line

  @override
  void initState() {
    super.initState();
    if (!isUserNameFetched) {
      fetchCurrentUserName();
    }
  }

  Future<void> fetchCurrentUserName() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot snapshot =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (mounted) {
          setState(() {
            currentUserName = snapshot.get('name');
            isUserNameFetched = true;
          });
        }
      } catch (e) {
        print('Error fetching current user name: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification's Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.import_contacts),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImportantPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> bloodDonationRequests = [];

          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            var requester = data['requester'];
            var recipientnm = data['recipient'];
            var timestamp = data['timestamp'];
            var status = data['status'];

            DateTime parsedTimestamp;
            if (timestamp is Timestamp) {
              parsedTimestamp = timestamp.toDate();
            } else if (timestamp is String) {
              parsedTimestamp = parseTimestamp(timestamp);
            } else {
              print('Unknown timestamp format');
              parsedTimestamp = DateTime.now(); // Default to current time
            }

            var formattedDate =
                "${parsedTimestamp.day}-${parsedTimestamp.month}-${parsedTimestamp.year} ${parsedTimestamp.hour}:${parsedTimestamp.minute}:${parsedTimestamp.second}";

            var currentUserNm = currentUserName;

            var pair = '$requester-$recipientnm';

            if (!facedPairs.contains(pair)) {
              facedPairs.add(pair);

              if (requester == currentUserNm || recipientnm == currentUserNm) {
                if (!bloodDonationRequests.contains(data)) {
                  bloodDonationRequests.add(data);
                }
              }
            }
          }

          return ListView.builder(
            itemCount: bloodDonationRequests.length,
            itemBuilder: (context, index) {
              var notification = bloodDonationRequests[index];
              var requester = notification['requester'];
              var requesterNum = notification['requesterNum'];
              var recipient = notification['recipient'];
              var timestamp = notification['timestamp'];
              var status = notification['status'];
              var number = notification['number'];

              Color cardColor = _getCardColor(status);

              DateTime parsedTimestamp;
              if (timestamp is Timestamp) {
                parsedTimestamp = timestamp.toDate();
              } else if (timestamp is String) {
                parsedTimestamp = parseTimestamp(timestamp);
              } else {
                print('Unknown timestamp format');
                parsedTimestamp = DateTime.now(); // Default to current time
              }

              var formattedDate =
                  "${parsedTimestamp.day}-${parsedTimestamp.month}-${parsedTimestamp.year} ${parsedTimestamp.hour}:${parsedTimestamp.minute}:${parsedTimestamp.second}";

              return Card(
                elevation: 4.0,
                child: Container(
                  color: cardColor,
                  child: ListTile(
                    title: Text(
                      'Blood Donation Request from $requester to $recipient',
                      style:
                          TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                    subtitle: Text(
                      'Date: $formattedDate',
                      style:
                          TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                    onTap: () {
                      _showDetailsDialog(
                          requester, recipient, formattedDate, status);
                    },
                    onLongPress: () {
                      _showOptionsDialog(requester, recipient, formattedDate,
                          number, status, requesterNum);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getCardColor(String status) {
    switch (status) {
      case 'pending':
        return const Color.fromARGB(255, 253, 195, 18);
      case 'accepted':
        return Color.fromARGB(255, 25, 108, 3);
      // Add more cases for other statuses if needed
      // case 'someOtherStatus':
      //   return Colors.someOtherColor;
      default:
        return Color.fromARGB(255, 255, 171, 25); // Default color
    }
  }

  DateTime parseTimestamp(String timestampString) {
    try {
      // Extract date and time from the string
      var dateTimeString = timestampString.split(' at ')[1];
      // Parse the date and time
      return DateTime.parse(dateTimeString);
    } catch (e) {
      print('Error parsing timestamp: $e');
      return DateTime.now(); // Default to current time if parsing fails
    }
  }

  void _showOptionsDialog(
    String requester,
    String recipient,
    String formattedDate,
    String number,
    String status,
    String requesterNum,
  ) {
    var currentUserNm = currentUserName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Options for $requester to $recipient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Delete Notification'),
                onTap: () async {
                  bool confirmed = await _showDeleteConfirmation(
                    context,
                    requester,
                    recipient,
                  );
                  if (confirmed) {
                    _deleteNotification(requester, recipient);
                  }
                  Navigator.pop(context);
                },
              ),
              if (status == 'accepted' && requester == currentUserNm) ...[
                ListTile(
                  title: Text('Call $number'),
                  onTap: () {
                    // FlutterPhoneDirectCaller.callNumber('+8801610585101');
                    _callPhoneNumber(number);
                    Navigator.pop(context);
                  },
                ),
              ] else ...[
                ListTile(
                  title: Text('Call $requesterNum'),
                  onTap: () {
                    // FlutterPhoneDirectCaller.callNumber('+8801610585101');
                    _callPhoneNumber(requesterNum);
                    Navigator.pop(context);
                  },
                ),
              ],
              ListTile(
                title: Text('Timestamp: $formattedDate'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _callPhoneNumber(String phoneNumber) async {
    Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    callnumber() async {
      await launchUrl(uri);
    }

    await FlutterPhoneDirectCaller.callNumber(phoneNumber);

    print(phoneNumber);
  }

  void _showDetailsDialog(
      String requester, String recipient, String formattedDate, String status) {
    showDialog(
      context: context,
      builder: (context) {
        bool isSameUser = requester == currentUserName;

        // Set the default color
        Color backgroundColor = Colors.white;

        // Check the status and update the color accordingly
        if (status == 'pending') {
          backgroundColor = Colors.orange;
        } else {
          backgroundColor = Color.fromARGB(255, 60, 167, 30);
        }

        return AlertDialog(
          title: Text('Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: backgroundColor, // Set the background color here
                child: Text('Status: $status'),
              ),
              Text('Requester: $requester'),
              Text('Recipient: $recipient'),
              Text('Timestamp: $formattedDate'),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (!isSameUser)
                    ElevatedButton(
                      onPressed: () {
                        if (status == 'pending') {
                          _updateStatusToAccepted(requester, recipient);
                        } else if (status == 'accepted') {
                          _updateStatusToPending(requester, recipient);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(status == 'pending' ? 'Accept' : 'Cancel'),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      bool confirmed = await _showDeleteConfirmation(
                          context, requester, recipient);
                      if (confirmed) {
                        _deleteNotification(requester, recipient);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Use red color for delete button
                    ),
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateStatusToPending(
      String requester, String recipient) async {
    try {
      await _firestore
          .collection('notifications')
          .where('requester', isEqualTo: requester)
          .where('recipient', isEqualTo: recipient)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var docId = querySnapshot.docs.first.id;
          _firestore
              .collection('notifications')
              .doc(docId)
              .update({'status': 'pending'});
        }
      });
    } catch (e) {
      print('Error updating status to pending: $e');
    }
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context, String requester, String recipient) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this notification?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirmed deletion
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Canceled deletion
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNotification(String requester, String recipient) async {
    try {
      // Find the document ID of the notification
      QuerySnapshot querySnapshot = await _firestore
          .collection('notifications')
          .where('requester', isEqualTo: requester)
          .where('recipient', isEqualTo: recipient)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Delete the notification document
        await querySnapshot.docs.first.reference.delete();

        // Show a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted successfully'),
          ),
        );

        print('Notification deleted successfully');
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> _updateStatusToAccepted(
      String requester, String recipient) async {
    try {
      await _firestore
          .collection('notifications')
          .where('requester', isEqualTo: requester)
          .where('recipient', isEqualTo: recipient)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var docId = querySnapshot.docs.first.id;
          _firestore
              .collection('notifications')
              .doc(docId)
              .update({'status': 'accepted'});
        }
      });
    } catch (e) {
      print('Error updating status: $e');
    }
  }
}
