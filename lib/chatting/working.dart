// import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';

// class ChatRoomPage extends StatefulWidget {
//   final String otherUserId;

//   const ChatRoomPage({Key? key, required this.otherUserId}) : super(key: key);

//   @override
//   _ChatRoomPageState createState() => _ChatRoomPageState();
// }

// class _ChatRoomPageState extends State<ChatRoomPage> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<String?> getUserName(String userId) async {
//     try {
//       DocumentSnapshot userSnapshot =
//           await _firestore.collection('users').doc(userId).get();
//       return userSnapshot['name'] as String?;
//     } catch (e) {
//       print('Error fetching user name: $e');
//       return null;
//     }
//   }

// // Keep track of the selected image
//   File? _selectedImage;

//   // Method to pick an image from the gallery
//   void _pickImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   // Method to upload an image to Firebase Storage and return the download URL
//   Future<String> _uploadImage(File imageFile) async {
//     try {
//       // Create a unique filename using the current timestamp
//       final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

//       // Reference to the Firebase Storage bucket and the file path
//       final Reference storageReference = FirebaseStorage.instance
//           .ref()
//           .child('your_bucket_name')
//           .child(fileName);

//       // Upload the image file to Firebase Storage
//       await storageReference.putFile(imageFile);

//       // Get the download URL for the uploaded image
//       final String downloadUrl = await storageReference.getDownloadURL();

//       // Return the download URL
//       return downloadUrl;
//     } catch (e) {
//       print('Error uploading image: $e');
//       throw e;
//     }
//   }

//   // Method to copy text to the clipboard
//   void _copyToClipboard(String text) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Copied to clipboard')),
//     );
//   }

//   // Method to send a message (text or image)
//   void _sendMessage() async {
//     final currentUser = _auth.currentUser;
//     final otherUserId = widget.otherUserId;

//     if (currentUser != null && otherUserId != null) {
//       final messageText = _messageController.text.trim();

//       if (messageText.isNotEmpty || _selectedImage != null) {
//         if (_selectedImage != null) {
//           // If an image is selected, upload the image and send a message with the image URL
//           String imageUrl = await _uploadImage(_selectedImage!);
//           await _firestore
//               .collection('demo_messages')
//               .doc(_chatRoomId())
//               .collection('chats')
//               .add({
//             'text': messageText,
//             'senderId': currentUser.uid,
//             'receiverId': otherUserId,
//             'timestamp': FieldValue.serverTimestamp(),
//             'image_url': imageUrl,
//           });
//         } else {
//           // If no image, send a regular text message
//           await _firestore
//               .collection('demo_messages')
//               .doc(_chatRoomId())
//               .collection('chats')
//               .add({
//             'text': messageText,
//             'senderId': currentUser.uid,
//             'receiverId': otherUserId,
//             'timestamp': FieldValue.serverTimestamp(),
//           });
//         }

//         // Clear the message controller and reset the selected image
//         _messageController.clear();
//         setState(() {
//           _selectedImage = null;
//         });
//       }
//     }
//   }

//   // Helper method to generate a unique chat room ID
//   String _chatRoomId() {
//     final currentUser = _auth.currentUser;
//     final otherUserId = widget.otherUserId;

//     if (currentUser != null) {
//       // Use a consistent order for combining user IDs to ensure uniqueness
//       final sortedUserIds = [currentUser.uid, otherUserId]..sort();
//       return '${sortedUserIds[0]}_${sortedUserIds[1]}';
//     }

//     throw Exception('Current user is null.');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat Room'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('demo_messages')
//                   .doc(_chatRoomId())
//                   .collection('chats')
//                   .orderBy('timestamp')
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 }

//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator();
//                 }

//                 final List<QueryDocumentSnapshot> messages =
//                     snapshot.data!.docs;

//                 // Inside the StreamBuilder builder function
//                 return ListView.builder(
                  
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message =
//                         messages[index].data() as Map<String, dynamic>;
//                     final messageText = message['text'] as String?;
//                     final imageUrl = message.containsKey('image_url')
//                         ? message['image_url'] as String
//                         : null;
//                     final senderId = message['senderId'] as String;
//                     final receiverId = message['receiverId'] as String;
//                     final currentUser = _auth.currentUser;

//                     return FutureBuilder<String?>(
//                       future: getUserName(senderId),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                                 ConnectionState.waiting ||
//                             snapshot.hasError) {
//                           return ListTile(
//                             title: Text('Loading...'),
//                           );
//                         }

//                         String senderName = snapshot.data ?? 'Unknown User';

//                         if (currentUser != null &&
//                             (senderId == currentUser.uid ||
//                                 receiverId == currentUser.uid)) {
//                           return GestureDetector(
//                             onLongPress: () {
//                               _copyToClipboard(messageText ??
//                                   ''); // Handle null for image messages
//                             },
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 if (imageUrl != null && imageUrl.isNotEmpty)
//                                   Container(
//                                     width: 200,
//                                     height: 200,
//                                     padding: EdgeInsets.all(12.0),
//                                     margin: EdgeInsets.only(
//                                       left: senderId == currentUser.uid
//                                           ? 200
//                                           : 10,
//                                       right:
//                                           senderId == currentUser.uid ? 10 : 50,
//                                     ),
//                                     child: Align(
//                                       alignment: senderId == currentUser.uid
//                                           ? Alignment.centerRight
//                                           : Alignment.centerLeft,
//                                       child: Image.network(
//                                         imageUrl,
//                                         width: 200,
//                                         height: 200,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   ),
//                                 if (messageText != null &&
//                                     messageText.isNotEmpty)
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: senderId == currentUser.uid
//                                           ? Colors.blue.withOpacity(0.5)
//                                           : Colors.grey.withOpacity(0.5),
//                                       borderRadius: BorderRadius.circular(8.0),
//                                     ),
//                                     padding: EdgeInsets.all(12.0),
//                                     margin: EdgeInsets.only(
//                                       left:
//                                           senderId == currentUser.uid ? 50 : 0,
//                                       right:
//                                           senderId == currentUser.uid ? 0 : 50,
//                                     ),
//                                     child: Align(
//                                       alignment: senderId == currentUser.uid
//                                           ? Alignment.centerRight
//                                           : Alignment.centerLeft,
//                                       child: Text(
//                                         messageText,
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           color: senderId == currentUser.uid
//                                               ? const Color.fromARGB(
//                                                   255, 0, 0, 0)
//                                               : Colors.black,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 Align(
//                                   alignment: senderId == currentUser.uid
//                                       ? Alignment.centerRight
//                                       : Alignment.centerLeft,
//                                   child: Text(
//                                     senderName,
//                                     style: TextStyle(
//                                       color: senderId == currentUser.uid
//                                           ? Colors.blue
//                                           : Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         } else {
//                           return Container();
//                         }
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type your message...',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.image),
//                   onPressed: () {
//                     _pickImage();
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     _sendMessage();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
