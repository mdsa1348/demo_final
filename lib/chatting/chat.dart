import 'package:demo/ThemeSwitch.dart';
import 'package:demo/chatting/chatroompage.dart';
import 'package:demo/chatting/userid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DemoChats extends StatefulWidget {
  final ThemeProviderNotifier themeProvider;
  const DemoChats({Key? key, required this.themeProvider}) : super(key: key);
  @override
  _DemoChatsState createState() => _DemoChatsState();
}

class _DemoChatsState extends State<DemoChats> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String otherUserId = '';
  Set<String> selectedUserIds = Set();
  List<String> selectedUserNames = [];

  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser?.uid ?? '';

    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Chat's List"),
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[700] // Dark theme background color
                : Colors.blue, // Light theme background color
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _navigateToShowAllUsers(context);
                },
              ),
            ],
          ),
          body: Container(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900]
                : const Color.fromARGB(255, 157, 157, 157),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : Color.fromARGB(255, 201, 199, 199),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchTerm = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search by Name',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _buildQuery(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print("${snapshot.error}");
                        return Text('Error: ${snapshot.error}');
                      }

                      // if (snapshot.connectionState == ConnectionState.waiting) {
                      //   return const CircularProgressIndicator();
                      // }

                      final List<QueryDocumentSnapshot> users =
                          (snapshot.data?.docs ?? [])
                              as List<QueryDocumentSnapshot>;

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final chatRoom = users[index];
                          final participants =
                              chatRoom['participants'] as List<dynamic>;

                          String otherUserId = participants.firstWhere(
                            (userId) => userId != currentUserId,
                            orElse: () => currentUserId,
                          ) as String;

                          return Dismissible(
                            key: Key(chatRoom.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20.0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              confirmDelete(chatRoom.id);
                            },
                            child: FutureBuilder<DocumentSnapshot>(
                              future: _firestore
                                  .collection('users')
                                  .doc(otherUserId)
                                  .get(),
                              builder: (context, snapshot) {
                                // if (snapshot.connectionState ==
                                //     ConnectionState.waiting) {
                                //   return CircularProgressIndicator();
                                // }

                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                final otherUserName =
                                    (snapshot.data?['name'] ?? '') as String;

                                String roomId =
                                    _GetchatRoomId(currentUserId, otherUserId);
                                print("ChatRoomId: $roomId");

                                return FutureBuilder<bool>(
                                  future: _isLastMessageSeen(roomId),
                                  builder: (context, snapshot) {
                                    // if (snapshot.connectionState ==
                                    //     ConnectionState.waiting) {
                                    //   return CircularProgressIndicator();
                                    // }

                                    bool isLastMessageSeen =
                                        snapshot.data ?? true;

                                    return FutureBuilder<String>(
                                      future: _getLastMessage(roomId),
                                      builder: (context, messageSnapshot) {
                                        // if (messageSnapshot.connectionState ==
                                        //     ConnectionState.waiting) {
                                        //   return CircularProgressIndicator();
                                        // }

                                        final lastMessage =
                                            messageSnapshot.data;

                                        return FutureBuilder<String>(
                                          future: _getLastMessageSender(roomId),
                                          builder: (context, senderSnapshot) {
                                            // if (senderSnapshot
                                            //         .connectionState ==
                                            //     ConnectionState.waiting) {
                                            //   return CircularProgressIndicator();
                                            // }

                                            final lastMessageSender =
                                                senderSnapshot.data;

                                            // Concatenate the strings based on the sender and include timestamp
                                            String displayText =
                                                lastMessageSender ==
                                                        currentUserId
                                                    ? 'You: $lastMessage '
                                                    : '$otherUserName: $lastMessage';

                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0, right: 10.0),
                                              child: Card(
                                                color: isLastMessageSeen
                                                    ? Colors.white
                                                    : Colors.blue[200],
                                                child: ListTile(
                                                  title: Text(
                                                    otherUserName,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    displayText,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  trailing:
                                                      FutureBuilder<String>(
                                                    future:
                                                        _getLastMessageTimestamp(
                                                            roomId),
                                                    builder:
                                                        (context, snapshot) {
                                                      // if (snapshot
                                                      //         .connectionState ==
                                                      //     ConnectionState
                                                      //         .waiting) {
                                                      //   return CircularProgressIndicator();
                                                      // }

                                                      final lastMessageTime =
                                                          snapshot.data ?? '';

                                                      print(
                                                          "Last Message Time: $lastMessageTime"); // Print the timestamp

                                                      return Text(
                                                        lastMessageTime,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black87),
                                                      );
                                                    },
                                                  ),
                                                  onTap: () async {
                                                    final result =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatRoomPage(
                                                          otherUserId:
                                                              otherUserId,
                                                        ),
                                                      ),
                                                    );
                                                    if (result == 'refresh') {
                                                      print("refreshed");
                                                      //await fetchDataFromFirebase();
                                                    }
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _isLastMessageSeen(String chatRoomId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('demo_messages')
          .doc(chatRoomId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        bool isSeen = snapshot.docs.first['seen'] ?? true;
        return isSeen;
      } else {
        return true; // Default to true if no message is available
      }
    } catch (e) {
      print('Error checking last message seen status: $e');
      return true; // Default to true in case of an error
    }
  }

  Future<String> _getLastMessageTimestamp(String chatRoomId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('demo_messages')
          .doc(chatRoomId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Timestamp timestamp = snapshot.docs.first['timestamp'];
        DateTime dateTime = timestamp.toDate();

        // Format the DateTime object to a string with only the time
        String formattedTime = DateFormat('HH:mm').format(dateTime);

        return formattedTime;
      } else {
        return 'No messages';
      }
    } catch (e) {
      print('Error getting last message timestamp: $e');
      return 'Error';
    }
  }

  String _formatTimestamp(String timestamp) {
    // Implement your custom formatting logic here.
    // You can use DateFormat from the intl package or any other formatting approach.
    return timestamp;
  }

  void confirmDelete(String chatRoomId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this chat room?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _firestore.collection('chat_rooms').doc(chatRoomId).delete();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                // Delete the chat room and its messages
                _deleteChatRoom();
                Navigator.of(context).pop();
              },
              child: Text('Delete entirely'),
            ),
          ],
        );
      },
    );
  }

  String _GetchatRoomId(String currentUserId, String otherUserId) {
    print("currentUserId : $currentUserId");
    print("otherUserId : $otherUserId");

    if (currentUserId != null) {
      // Use a consistent order for combining user IDs to ensure uniqueness
      final sortedUserIds = [currentUserId, otherUserId]..sort();
      return '${sortedUserIds[0]}_${sortedUserIds[1]}';
    }

    throw Exception('Current user is null.');
  }

  String _chatRoomId() {
    final currentUser = _auth.currentUser;
    final othersUserId = otherUserId;
    // print("currentUser : $currentUser");

    print("othersUserId : $othersUserId");
    if (currentUser != null) {
      // Use a consistent order for combining user IDs to ensure uniqueness
      final sortedUserIds = [currentUser.uid, othersUserId]..sort();
      return '${sortedUserIds[0]}_${sortedUserIds[1]}';
    }

    throw Exception('Current user is null.');
  }

  void _deleteChatRoom() async {
    try {
      await _firestore
          .collection('demo_messages')
          .doc(_chatRoomId()) // Correct syntax for string interpolation
          .collection('chats')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
    } catch (e) {
      print('Error deleting chat room: $e');
    }
  }

  Future<String> _getLastMessageSender(String chatRoomId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('demo_messages')
          .doc(chatRoomId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['senderId'] ?? 'No sender';
      } else {
        return 'No sender';
      }
    } catch (e) {
      print('Error getting last message sender: $e');
      return 'Error';
    }
  }

  Future<String> _getLastMessage(String chatRoomId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('demo_messages')
          .doc(chatRoomId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      //print('chatRoomId: $chatRoomId');

      if (snapshot.docs.isNotEmpty) {
        //print('Message exists');
        //print('Message data: ${snapshot.docs.first.data()}');
        // print('Message: ${snapshot.docs.first['text']}'); // Use 'text' instead of 'message'
        return snapshot.docs.first['text'] ?? 'No messages';
      } else {
        print('No documents found');
        return 'No messages';
      }
    } catch (e) {
      print('Error getting last message: $e');
      return 'Error';
    }
  }

  Future<void> _addSelectedUsersToChatList() async {
    String currentUserId = _auth.currentUser?.uid ?? '';

    for (String userId in selectedUserIds) {
      List<String> participants = [currentUserId, userId];
      participants.sort();

      bool chatRoomExists = await _doesChatRoomExist(participants);
      print('Chat room already exists for participants: $chatRoomExists');

      if (!chatRoomExists && _isMounted) {
        await _firestore.collection('chat_rooms').add({
          'participants': participants,
          'sortedParticipants': participants
              .join('_'), // Concatenate and store in a separate field
        });
      } else if (_isMounted) {
        print('Chat room already exists for participants: $participants');
      }
    }
  }

  Future<bool> _doesChatRoomExist(List<String> participants) async {
    try {
      final sortedParticipants =
          participants.join('_'); // Concatenate and store in a separate field
      final querySnapshot = await _firestore
          .collection('chat_rooms')
          .where('sortedParticipants', isEqualTo: sortedParticipants)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking chat room existence: $e');
      return false; // Handle the error and return a default value
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _buildQuery() {
    String currentUserId = _auth.currentUser?.uid ?? '';

    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .snapshots();
  }

  void _navigateToShowAllUsers(BuildContext context) async {
    Set<String>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowAllUsers(
          onUsersSelected: (users) {
            setState(() {
              selectedUserIds = users;
            });
            _addSelectedUsersToChatList();
          },
          auth: _auth,
        ),
      ),
    );
  }
}

class ShowAllUsers extends StatefulWidget {
  final Function(Set<String> selectedUsers) onUsersSelected;
  final FirebaseAuth auth;

  ShowAllUsers({required this.onUsersSelected, required this.auth});

  @override
  _ShowAllUsersState createState() => _ShowAllUsersState(auth: auth);
}

class _ShowAllUsersState extends State<ShowAllUsers> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedUserId = ''; // Updated to a single userId
  final FirebaseAuth auth;
  String _searchTerm = '';

  _ShowAllUsersState({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('All Users'),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.themeMode == ThemeMode.dark
                  ? null
                  : LinearGradient(
                      colors: [
                        Color(0xff85ffc0),
                        Color(0xff7eade7),
                        Color(0xff80ffd9)
                      ],
                      stops: [0.1, 0.5, 1],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                    ),
              color: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.grey[900]
                  : null,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchTerm = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search by Name',
                            hintStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(Icons.search),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      // if (snapshot.connectionState == ConnectionState.waiting) {
                      //   return const CircularProgressIndicator();
                      // }

                      final List<QueryDocumentSnapshot> users =
                          (snapshot.data?.docs ?? [])
                              as List<QueryDocumentSnapshot>;

                      return Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final userName = user['name'] as String;
                            final userId = user.id;

                            if (_searchTerm.isEmpty ||
                                userName
                                    .toLowerCase()
                                    .contains(_searchTerm.toLowerCase())) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // Allow selecting only one user at a time
                                      selectedUserId = (selectedUserId ==
                                              userId)
                                          ? '' // Unselect the user if already selected
                                          : userId;
                                    });
                                  },
                                  child: Card(
                                    color: (selectedUserId == userId)
                                        ? Colors.blue[200]
                                        : Colors.white,
                                    child: ListTile(
                                      title: Text(
                                        userName,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (selectedUserId.isNotEmpty) {
                widget.onUsersSelected(Set<String>.from([selectedUserId]));
                Navigator.pop(context);
              } else {
                // Handle the case where no user is selected
                // You may show a message or prevent closing the page
              }
            },
            child: Icon(Icons.check),
          ),
        );
      },
    );
  }
}
