import 'dart:io';

import 'package:demo/ThemeSwitch.dart';
import 'package:demo/chatting/chat.dart';
import 'package:demo/notification/blood_notification/important.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class ChatRoomPage extends StatefulWidget {
  final String otherUserId;

  const ChatRoomPage({Key? key, required this.otherUserId}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getUserName(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();
      return userSnapshot['name'] as String?;
    } catch (e) {
      print('Error fetching user name: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    // Call _markMessagesAsSeen when the widget is initialized
    _markMessagesAsSeen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle lifecycle state changes (e.g., app comes to the foreground)
    if (state == AppLifecycleState.resumed) {
      // Call _markMessagesAsSeen when the app is resumed
      _markMessagesAsSeen();
    }
  }

  // Mark all messages as seen
  void _markMessagesAsSeen() async {
    try {
      await _firestore
          .collection('demo_messages')
          .doc(_chatRoomId())
          .collection('chats')
          .where('seen', isEqualTo: false)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'seen': true});
        });
      });
    } catch (e) {
      print('Error marking messages as seen: $e');
    }
  }

// Keep track of the selected image
  File? _selectedImage;

  // Method to pick an image from the gallery
  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedImageUrl = null; // Reset the selected image URL
        _uploadProgress = 0.0; // Reset the upload progress
      });
    }
  }

  // Method to upload an image to Firebase Storage and return the download URL
  Future<void> _uploadImage(File imageFile) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('your_bucket_name')
          .child(fileName);

      final UploadTask uploadTask = storageReference.putFile(imageFile);

      // Listen for changes in the upload task
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      // Wait for the upload to complete
      await uploadTask;

      final String downloadUrl = await storageReference.getDownloadURL();
      setState(() {
        _uploadProgress = 1.0; // Set progress to 100% when upload is complete
        _selectedImageUrl = downloadUrl;
      });

      // Hide the progress bar after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _uploadProgress = 0.0;
        });
      });
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  void _showContextMenu(BuildContext context, String? messageText,
      Timestamp timestamp, Offset tapPosition) {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final Offset overlayPosition = overlay.localToGlobal(Offset.zero);
    final Offset localPosition = tapPosition - overlayPosition;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        localPosition.dx,
        localPosition.dy,
        localPosition.dx + 1.0,
        localPosition.dy + 1.0,
      ),
      items: [
        const PopupMenuItem(
          value: 'copy',
          child: Text('Copy'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('delete'),
        ),
        PopupMenuItem(
          value: 'time',
          child: Text('Time: ${_formatTimestamp(timestamp)}'),
        ),
      ],
    ).then((value) {
      if (value == 'copy') {
        _copyToClipboard(messageText ?? '');
      }
      if (value == 'delete') {
        _deleteMessage(timestamp);
      }
    });

    // GestureRecognizer callback for long press
  }

  void _deleteMessage(Timestamp timestamp) async {
    try {
      await _firestore
          .collection('demo_messages')
          .doc(_chatRoomId())
          .collection('chats')
          .where('timestamp', isEqualTo: timestamp)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  // Helper method to show the image in a dialog
  void _showImageDialog(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height *
                    0.15), // Adjust the margin as needed
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(imageUrl),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                  );
                },
                itemCount: 1,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                pageController: PageController(),
                onPageChanged: (index) {},
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleLongPress(BuildContext context, LongPressStartDetails details,
      String? messageText, Timestamp timestamp) {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final Offset tapPosition = overlay.globalToLocal(details.globalPosition);
    _showContextMenu(context, messageText, timestamp, tapPosition);
  }

// Helper method to format the timestamp
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final String formattedTime = '${dateTime.hour}:${dateTime.minute}';
    return formattedTime;
  }

  // Method to copy text to the clipboard
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  // Method to send a message (text or image)
  // Method to send a message (text or image)
  void _sendMessage() async {
    final currentUser = _auth.currentUser;
    final otherUserId = widget.otherUserId;

    if (currentUser != null && otherUserId != null) {
      final messageText = _messageController.text.trim();

      if (messageText.isNotEmpty || _selectedImage != null) {
        setState(() {
          _uploadProgress = 0.0; // Reset progress before starting the upload
        });

        if (_selectedImage != null) {
          try {
            await _uploadImage(_selectedImage!);
            await _firestore
                .collection('demo_messages')
                .doc(_chatRoomId())
                .collection('chats')
                .add({
              'text': messageText,
              'senderId': currentUser.uid,
              'receiverId': otherUserId,
              'timestamp': FieldValue.serverTimestamp(),
              'image_url': _selectedImageUrl,
              'seen': false, // Add 'seen' field to track the status
            });

            // Clear the selected image URL after sending the message
            setState(() {
              _selectedImageUrl = null;
            });
          } catch (e) {
            print('Error sending image message: $e');
          }
        } else {
          await _firestore
              .collection('demo_messages')
              .doc(_chatRoomId())
              .collection('chats')
              .add({
            'text': messageText,
            'senderId': currentUser.uid,
            'receiverId': otherUserId,
            'timestamp': FieldValue.serverTimestamp(),
            'seen': false, // Add 'seen' field to track the status
          });
        }

        // Clear the message controller and reset the selected image
        _messageController.clear();
        setState(() {
          _selectedImage = null;
        });
      }
    }
  }

// Mark the message as seen
  void _markMessageAsSeen(Timestamp timestamp) async {
    try {
      await _firestore
          .collection('demo_messages')
          .doc(_chatRoomId())
          .collection('chats')
          .where('timestamp', isEqualTo: timestamp)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'seen': true});
        });
      });
    } catch (e) {
      print('Error marking message as seen: $e');
    }
  }

  // Helper method to generate a unique chat room ID
  String _chatRoomId() {
    final currentUser = _auth.currentUser;
    final otherUserId = widget.otherUserId;

    print("chatroom otherUserId :" + otherUserId);
    if (currentUser != null) {
      // Use a consistent order for combining user IDs to ensure uniqueness
      final sortedUserIds = [currentUser.uid, otherUserId]..sort();
      return '${sortedUserIds[0]}_${sortedUserIds[1]}';
    }

    throw Exception('Current user is null.');
  }

  void _deleteChatRoom() async {
    try {
      await _firestore
          .collection('demo_messages')
          .doc(_chatRoomId())
          .collection('chats')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
      // Use Navigator.pop to navigate back to the previous screen with a result
      Navigator.pop(context, true);
    } catch (e) {
      print('Error deleting chat room: $e');
    }
  }

  // Add a variable to hold the selected image URL
  String? _selectedImageUrl;
  double _uploadProgress = 0.0;

  //final otherUserId = widget.otherUserId;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Your logic here before popping the page
        print('Back button pressed');
        // Perform any actions you want before popping the page
        // Inside _deleteChatRoom or any method where you navigate back
        Navigator.pop(context, 'refresh');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DemoChats(
              themeProvider: Provider.of<ThemeProviderNotifier>(context),
            ),
          ),
        );
        // Return true to allow the page to be popped
        return true;
      },
      child: Consumer<ThemeProviderNotifier>(
        builder: (context, themeProvider, child) {
          return Scaffold(
            appBar: AppBar(
              title: FutureBuilder<String?>(
                future: getUserName(widget.otherUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading...");
                  } else if (snapshot.hasError) {
                    return Text("Error");
                  } else {
                    // Use the fetched user name in the title with the first letter in uppercase
                    final userName = snapshot.data ?? "Other User";
                    final capitalizedUserName = userName.isNotEmpty
                        ? userName[0].toUpperCase() + userName.substring(1)
                        : "";
                    return Text(capitalizedUserName);
                  }
                },
              ),
              backgroundColor: themeProvider.themeMode == ThemeMode.dark
                  ? Color.fromARGB(255, 0, 0, 0)
                  : Color.fromARGB(255, 173, 172, 172),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    // Handle the selected menu item
                    if (value == 'Delete_Chatroom') {
                      _deleteChatRoom();
                    } else if (value == 'menuItem2') {
                      ImportantPage();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'Delete_Chatroom',
                        child: Text('Delete Chatroom'),
                      ),
                      const PopupMenuItem(
                        value: 'menuItem2',
                        child: Text('Menu Item 2'),
                      ),
                      // Add more menu items as needed
                    ];
                  },
                ),
              ],
            ),
            body: Container(
              color: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.grey[900] // Dark theme background color
                  : Color.fromARGB(255, 241, 241, 241),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('demo_messages')
                          .doc(_chatRoomId())
                          .collection('chats')
                          .orderBy('timestamp')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final List<QueryDocumentSnapshot> messages =
                            snapshot.data!.docs;

                        return ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final reversedIndex = messages.length - 1 - index;
                            final message = messages[reversedIndex].data()
                                as Map<String, dynamic>;
                            final messageText = message['text'] as String?;
                            final timestamp =
                                message['timestamp'] as Timestamp? ??
                                    Timestamp.now();

                            final imageUrl = message.containsKey('image_url')
                                ? message['image_url'] as String
                                : null;
                            final senderId = message['senderId'] as String;
                            final receiverId = message['receiverId'] as String;
                            final currentUser = _auth.currentUser;

                            // Call _markMessageAsSeen when a message becomes visible
                            // WidgetsBinding.instance?.addPostFrameCallback((_) {
                            //   _markMessageAsSeen(timestamp);
                            // });

                            return FutureBuilder<List<String?>>(
                              future: Future.wait([
                                getUserName(senderId),
                                getUserName(receiverId),
                              ]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    snapshot.hasError) {
                                  return const ListTile(
                                    title: Text('Loading...'),
                                  );
                                }

                                String senderName =
                                    snapshot.data![0] ?? 'Unknown Sender';
                                String receiverName =
                                    snapshot.data![1] ?? 'Unknown Receiver';

                                if (currentUser != null &&
                                    (senderId == currentUser.uid ||
                                        receiverId == currentUser.uid)) {
                                  return GestureDetector(
                                    onLongPressStart: (details) {
                                      _handleLongPress(context, details,
                                          messageText, timestamp);
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (imageUrl != null &&
                                            imageUrl.isNotEmpty)
                                          Container(
                                            width: 200,
                                            height: 200,
                                            padding: const EdgeInsets.all(12.0),
                                            margin: EdgeInsets.only(
                                              left: senderId == currentUser.uid
                                                  ? 200
                                                  : 10,
                                              right: senderId == currentUser.uid
                                                  ? 10
                                                  : 50,
                                            ),
                                            child: Align(
                                              alignment:
                                                  senderId == currentUser.uid
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                              child: GestureDetector(
                                                onTap: () {
                                                  _showImageDialog(
                                                      context, imageUrl);
                                                },
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 200,
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (messageText != null &&
                                            messageText.isNotEmpty)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: senderId == currentUser.uid
                                                  ? Color.fromARGB(
                                                          255, 227, 190, 69)
                                                      .withOpacity(0.5)
                                                  : const Color.fromARGB(
                                                          255, 251, 209, 209)
                                                      .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            padding: const EdgeInsets.all(12.0),
                                            margin: EdgeInsets.only(
                                              left: senderId == currentUser.uid
                                                  ? 50
                                                  : 0,
                                              right: senderId == currentUser.uid
                                                  ? 0
                                                  : 50,
                                            ),
                                            child: Align(
                                              alignment:
                                                  senderId == currentUser.uid
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                              child: Text(
                                                messageText,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: senderId ==
                                                          currentUser.uid
                                                      ? Color.fromARGB(
                                                              255, 0, 0, 0)
                                                          .withOpacity(1)
                                                      : Color.fromARGB(
                                                              255, 0, 0, 0)
                                                          .withOpacity(1),
                                                ),
                                              ),
                                            ),
                                          ),
                                        Align(
                                          alignment: senderId == currentUser.uid
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Text(
                                            senderName,
                                            style: TextStyle(
                                              color: senderId == currentUser.uid
                                                  ? Colors.blue
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Display the selected image preview and progress bar
                  if (_selectedImage != null || _uploadProgress > 0)
                    Container(
                      color: Colors.green[300],
                      width: double.infinity,
                      height: 140,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Display the selected image preview
                          if (_selectedImage != null)
                            Image.file(
                              _selectedImage!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          // Display the progress bar
                          if (_uploadProgress > 0)
                            LinearProgressIndicator(
                              value: _uploadProgress,
                              backgroundColor: Colors.grey[400],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.green),
                            ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                            ),
                            style: TextStyle(
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? Color.fromARGB(255, 255, 255,
                                      255) // Dark theme background color
                                  : Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.image),
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? Color.fromARGB(255, 221, 220,
                                  220) // Dark theme background color
                              : Color.fromARGB(255, 2, 2, 2),
                          onPressed: () {
                            _pickImage();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? Color.fromARGB(255, 221, 220,
                                  220) // Dark theme background color
                              : Color.fromARGB(255, 2, 2, 2),
                          onPressed: () {
                            _sendMessage();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
