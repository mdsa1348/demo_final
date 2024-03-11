import 'dart:io'; // Import the dart:io library for File handling

import 'package:firebase_storage/firebase_storage.dart'; // Import the Firebase Storage package
import 'package:flutter/material.dart'; // Import the Flutter material library
import 'package:image_picker/image_picker.dart'; // Import the Image Picker package
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage; // Import Firebase Storage with an alias
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage package

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _selectedImage; // Variable to hold the selected image file
  String _downloadUrl = ''; // Variable to hold the download URL of the uploaded image
  UploadTask? _uploadTask; // Variable to hold the upload task

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  // Method to upload the selected image to Firebase Storage
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      // Handle no image selected
      return;
    }

    try {
      final storage = firebase_storage.FirebaseStorage.instance;
      final ref = storage.ref().child('images/${DateTime.now().toString()}');
      _uploadTask = ref.putFile(_selectedImage!);

      // Listen to the task completion and update the download URL
      _uploadTask!.then((snapshot) async {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          _downloadUrl = downloadUrl;
        });
      });
    } catch (e) {
      // Handle errors during upload
      print("Error uploading image: $e");
    }
  }

  // Build method to create the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                : Container(),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
            _uploadTask != null
                ? StreamBuilder<TaskSnapshot>(
                    stream: _uploadTask!.snapshotEvents,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final progress =
                            snapshot.data!.bytesTransferred.toDouble() /
                                snapshot.data!.totalBytes.toDouble();
                        return LinearProgressIndicator(value: progress);
                      } else {
                        return Container();
                      }
                    },
                  )
                : Container(),
            _downloadUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: _downloadUrl,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
