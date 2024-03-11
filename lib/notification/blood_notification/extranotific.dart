//ooooooooooooofffffff
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            //var reversePair = '$recipientnm-$requester';

            // Check if the pair or its reverse is already in the set
            //!facedPairs.contains(reversePair)
            if (!facedPairs.contains(pair)) {
              facedPairs.add(pair);

              if (requester == currentUserNm || recipientnm == currentUserNm) {
                if (!bloodDonationRequests.contains(data)) {
                  bloodDonationRequests.add(data);
                }
              }

              // Print statements for debugging
              print("requesterId: $requester ; currentuser id :$currentUserNm");
              print(
                  "recipientId: $recipientnm ; currentuser nm :$currentUserNm");
            }
          }

          return ListView.builder(
            itemCount: bloodDonationRequests.length,
            itemBuilder: (context, index) {
              var notification = bloodDonationRequests[index];
              var requester = notification['requester'];
              var recipient = notification['recipient'];
              var timestamp = notification['timestamp'];

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
                child: ListTile(
                  title: Text(
                      'Blood Donation Request from $requester to $recipient'),
                  subtitle: Text('Date: $formattedDate'),
                  onTap: () {
                    _showDetailsDialog(requester, recipient, formattedDate);
                  },
                  onLongPress: () {
                    _showOptionsDialog(requester, recipient, formattedDate);
                  },
                ),
              );
            },
          );
        },
      ),
    );
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
      String requester, String recipient, String formattedDate) {
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
                      context, requester, recipient);
                  if (confirmed) {
                    _deleteNotification(requester, recipient);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Call $requester'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Timestamp: $formattedDate'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDetailsDialog(
      String requester, String recipient, String formattedDate) {
    showDialog(
      context: context,
      builder: (context) {
        bool isSameUser = requester == currentUserName;

        return AlertDialog(
          title: Text('Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        _sendNotificationToFirebase(requester, recipient);
                        Navigator.pop(context);
                      },
                      child: Text('Accept'),
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

  Future<void> _sendNotificationToFirebase(
      String requester, String recipient) async {
    // Add your logic to send a notification to Firebase
    var strng = "Accepted your request.";
    await FirebaseFirestore.instance.collection('notifications').add({
      'Recipient': requester,
      'requesterid': recipient,
      'string': strng,
      'timestamp': FieldValue.serverTimestamp(),
    });
    // You can use Firebase Cloud Messaging (FCM) or another appropriate method
    // For simplicity, let's print a message here
    print('Notification sent to $requester');
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
}
