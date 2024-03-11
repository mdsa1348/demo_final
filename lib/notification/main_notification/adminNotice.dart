import 'dart:io';

import 'package:demo/notification/main_notification/adminnoticeDetails.dart';
import 'package:demo/notification/main_notification/notification_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Notice {
  final String title;
  final String description;
  final String imageUrl;

  Notice({required this.title, required this.description, this.imageUrl = ''});
}

class NoticeBoard extends StatefulWidget {
  @override
  _NoticeBoardState createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  List<Notice> notices = [];
  late List<DocumentSnapshot> localDocuments;

  CollectionReference noticesCollection =
      FirebaseFirestore.instance.collection('notices');

  FirebaseStorage storage = FirebaseStorage.instance;

  void addNotice(Notice notice) async {
    // Upload image to Firebase Storage
    String imageUrl = '';
    if (notice.imageUrl.isNotEmpty) {
      Reference ref = storage.ref().child('images/${DateTime.now()}.jpg');
      UploadTask uploadTask = ref.putFile(File(notice.imageUrl));
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    // Add notice data to Firestore
    noticesCollection.add({
      'title': notice.title,
      'description': notice.description,
      'imageUrl': imageUrl,
    });

    // Update UI
    setState(() {
      notices.add(notice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admins Notice Board'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: noticesCollection.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                localDocuments =
                    snapshot.data!.docs; // Update the documents list

                if (localDocuments.isEmpty) {
                  return Center(
                    child: Text('No data available'),
                  );
                }

                return ListView.builder(
                  itemCount: localDocuments.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        localDocuments[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(data['title']),
                        subtitle: Text(
                          data['description'],
                          maxLines: 4,
                        ),
                        leading: data['imageUrl'].isNotEmpty
                            ? Image.network(data['imageUrl'])
                            : null,
                        onTap: () {
                          // Navigate to NoticeDetail page when a notice is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoticeDetail(
                                title: data['title'],
                                description: data['description'],
                                imageUrl: data['imageUrl'],
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          // Show a bottom sheet with options to edit or delete the notice
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                    onTap: () {
                                      Navigator.pop(
                                          context); // Close the bottom sheet
                                      _showEditNoticeDialog(
                                          context, data, index);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete'),
                                    onTap: () async {
                                      // Ensure that index is within the bounds of localDocuments
                                      if (index >= 0 &&
                                          index < localDocuments.length) {
                                        // Get the document reference
                                        DocumentReference documentReference =
                                            noticesCollection
                                                .doc(localDocuments[index].id);

                                        // Delete the document from Firestore
                                        await documentReference.delete();
                                      }
                                      //_showDeleteConfirmationDialog();
                                      // Close the bottom sheet
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                    SizedBox(
                      height: 8,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNoticeDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this doctor?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deletenotice();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.redAccent),
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deletenotice() async {
    // Get the document reference
    //DocumentReference documentReference =noticesCollection.doc(localDocuments[index].id);

    // Delete the document from Firestore
    //await documentReference.delete();

    Navigator.of(context).pop();
  }

  String? imageUrl;
  Future<void> _showEditNoticeDialog(
      BuildContext context, Map<String, dynamic> data, int index) async {
    TextEditingController titleController =
        TextEditingController(text: data['title']);
    TextEditingController descriptionController =
        TextEditingController(text: data['description']);
    imageUrl = data['imageUrl'].isNotEmpty ? data['imageUrl'] : null;

    File? newImageFile;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Notice'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 4,
                ),
                TextButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      setState(() {
                        newImageFile = File(pickedFile.path);
                      });
                    }
                  },
                  child: Text('Pick Image'),
                ),
                newImageFile != null ? Image.file(newImageFile!) : Container(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog to prevent multiple state updates
                Navigator.of(context).pop();

                // Update the notice in Firestore and Firebase Storage
                String updatedImageUrl = imageUrl ?? data['imageUrl'];

                if (newImageFile != null && newImageFile!.existsSync()) {
                  Reference ref =
                      storage.ref().child('images/${DateTime.now()}.jpg');
                  UploadTask uploadTask = ref.putFile(newImageFile!);
                  TaskSnapshot snapshot = await uploadTask;
                  updatedImageUrl = await snapshot.ref.getDownloadURL();
                }

                noticesCollection.doc(localDocuments[index].id).update({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'imageUrl': updatedImageUrl,
                });
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNoticeDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    XFile? imageFile;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Notice'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      setState(() {
                        imageFile = XFile(pickedFile.path);
                      });
                    }
                  },
                  child: Text('Pick Image'),
                ),
                imageFile != null
                    ? Image.file(File(imageFile!.path))
                    : Container(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add the notice to Firestore and Firebase Storage
                addNotice(
                  Notice(
                    title: titleController.text,
                    description: descriptionController.text,
                    imageUrl: imageFile?.path ?? '',
                  ),
                );

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
