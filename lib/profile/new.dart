import 'dart:io'; // Importing the dart:io library for file operations
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firestore for database operations
import 'package:demo/ThemeSwitch.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importing FirebaseAuth for user authentication
import 'package:firebase_storage/firebase_storage.dart'; // Importing FirebaseStorage for file storage
import 'package:flutter/material.dart'; // Importing the Flutter material library
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; // Importing the ImagePicker package

class MyProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() =>
      _ProfilePageState(); // Creating the stateful widget
}

class _ProfilePageState extends State<MyProfilePage> {
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Initializing FirebaseAuth instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Initializing Firestore instance
  final int minMonthsBetweenImageChanges =
      1; // Setting a minimum duration between image changes

  String? _imageUrl; // Variable to store the URL of the user's profile image
  String _name = ''; // Variable to store the user's name
  String _number = ''; // Variable to store the user's phone number
  String _address = ''; // Variable to store the user's address
  String _bloodGroup = ''; // Variable to store the user's blood group
  DateTime?
      _lastImageUpdateTime; // Variable to store the last time the user's image was updated
  DateTime?
      _lastDonationDate; // Variable to store the last donation date of the user
  DateTime?
      _lastImagePickTime; // New variable to store the last time an image was picked
  File? _imageFile; // Variable to store the user's profile image file

  @override
  void initState() {
    super.initState();
    loadData(); // Loading the user data when the widget is initialized
  }

  bool _isLoading = false;

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });

    // Simulate an asynchronous operation (e.g., fetching data)
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> loadData() async {
    User? user = _auth.currentUser; // Getting the current user

    if (user != null) {
      DocumentReference<Map<String, dynamic>> userDocRef = _firestore
          .collection('users')
          .doc(user.uid); // Reference to the user's document in Firestore

      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await userDocRef.get(); // Getting the user's document snapshot

      if (snapshot.exists) {
        // Existing user data found, load it
        setState(() {
          _name =
              snapshot.data()?['name'] ?? ''; // Setting the name from Firestore
          _number = snapshot.data()?['number'] ??
              ''; // Setting the number from Firestore
          _address = snapshot.data()?['address'] ??
              ''; // Setting the address from Firestore
          _bloodGroup = snapshot.data()?['bloodGroup'] ??
              ''; // Setting the blood group from Firestore
          String imageUrl = snapshot.data()?['imageUrl'] ??
              ''; // Getting the image URL from Firestore
          _lastImageUpdateTime =
              (snapshot.data()?['lastImageUpdateTime'] as Timestamp?)
                  ?.toDate(); // Getting the last image update time

          _lastDonationDate =
              (snapshot.data()?['lastDonationDate'] as Timestamp?)
                  ?.toDate(); // Getting the last donation date

          if (imageUrl.isNotEmpty) {
            setState(() {
              _imageFile = null; // Clearing the image file
              _imageUrl = imageUrl; // Setting the image URL
            });
          }
        });
      } else {
        // Document does not exist, create it
        await userDocRef.set({
          'name': '',
          'number': '',
          'address': '',
          'email': '',
          'bloodGroup': '',
          'imageUrl': '',
          'lastImageUpdateTime': null,
          'lastDonationDate': null,
        });

        // Now, load the data (will be empty initially)
        await loadData();
      }
    }
  }

  Future<String> updateData() async {
    User? user = _auth.currentUser; // Getting the current user
    String userEmail = user?.email ?? 'No email available';

    if (user != null) {
      try {
        String imageUrl = await uploadImageToStorage(
            user.uid); // Uploading the image to Firebase Storage

        // Update the user data
        Map<String, dynamic> userData = {
          'name': _name,
          'number': _number,
          'address': _address,
          'email': userEmail,
          'bloodGroup': _bloodGroup,
          'lastDonationDate': _lastDonationDate != null
              ? Timestamp.fromDate(_lastDonationDate!)
              : null,
        };

        // Add imageUrl to userData if it is not empty
        if (imageUrl.isNotEmpty) {
          userData['imageUrl'] = imageUrl;
        }

        await _firestore
            .collection('users')
            .doc(user.uid)
            .update(userData); // Updating user data in Firestore

        // Reload the updated data
        await loadData();

        // Clear the image file after a successful update
        setState(() {
          _imageFile = null;
        });

        return imageUrl; // Returning the image URL
      } catch (e) {
        print("Error updating user data: $e");
        return '';
      }
    }

    return '';
  }

  Future<String> uploadImageToStorage(String userId) async {
    if (_imageFile != null) {
      try {
        Reference storageReference = FirebaseStorage.instance.ref().child(
            'user_images/$userId.jpg'); // Reference to the storage location
        UploadTask uploadTask =
            storageReference.putFile(_imageFile!); // Uploading the file

        TaskSnapshot snapshot =
            await uploadTask; // Getting the upload task snapshot
        String downloadUrl =
            await snapshot.ref.getDownloadURL(); // Getting the download URL
        return downloadUrl; // Returning the download URL
      } catch (e) {
        print("Error uploading image: $e");
        return '';
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('My Profile'),
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[700] // Dark theme background color
                : Colors.blue, // Light theme background color
          ),
          body: Container(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900]
                : Colors.white,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: ClipOval(
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: _imageFile != null
                              ? Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                )
                              : _imageUrl != null
                                  ? Image.network(
                                      _imageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Placeholder(
                                      fallbackHeight: 100,
                                      fallbackWidth: 100,
                                    ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInfoBox('Name', _name),
                    _buildInfoBox('Number', _number),
                    _buildInfoBox('Address', _address),
                    _buildInfoBox('Blood Group', _bloodGroup),
                    _buildInfoBox(
                        'Last Donation Date',
                        _lastDonationDate != null
                            ? _lastDonationDate!.toLocal().toString()
                            : 'Not available'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _showEditDialog();
                      },
                      child: Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final GlobalKey<ScaffoldState> _scaffoldKey =
            GlobalKey<ScaffoldState>();

        return AlertDialog(
          key: _scaffoldKey,
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Name', _name, (val) {
                  setState(() {
                    _name = val;
                  });
                }),
                _buildTextField('Number', _number, (val) {
                  setState(() {
                    _number = val;
                  });
                }),
                _buildTextField('Address', _address, (val) {
                  setState(() {
                    _address = val;
                  });
                }),
                _buildTextField('Blood Group', _bloodGroup, (val) {
                  setState(() {
                    _bloodGroup = val;
                  });
                }),
                SizedBox(height: 20),
                _buildDatePicker('Last Donation Date', _lastDonationDate),
                SizedBox(height: 16),
                _buildImagePicker(),
                // if (_lastDonationDate != null)
                //   Padding(
                //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                //     child: Text(
                //       'Selected Date: ${_lastDonationDate!.toLocal()}',
                //       style: TextStyle(fontSize: 16),
                //     ),
                //   ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                _startLoading();
                final snackBar = SnackBar(
                  content: Text('Updating profile...'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green, // Set your desired color
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                await updateData();
                await loadData();
                setState(() {
                  _imageFile = null;
                  _lastDonationDate = null; // Add this line
                  _isLoading = false;
                });

                Navigator.pop(context);
              },
              child: Text('Saving'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoBox(String label, String value) {
    Brightness themeBrightness = Theme.of(context).brightness;
    Color boxColor = themeBrightness == Brightness.light
        ? Color.fromARGB(255, 163, 163, 163) // Light theme color
        : Color.fromARGB(255, 73, 58, 58); // Dark theme color

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    void Function(String) onChanged,
  ) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
      controller: TextEditingController(text: value),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 8),
        if (_lastDonationDate != null)
          Text(
            'Selected Date: ${_lastDonationDate!.toLocal()}',
            style: TextStyle(fontSize: 15),
          ),
        SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: date ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _lastDonationDate = pickedDate;
                  });
                }
              },
              child: Text('Select Date'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile Image'),
        SizedBox(height: 8),
        Container(
          height: 100,
          width: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              if (_imageUrl != null)
                Image.network(
                  _imageUrl!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: _isImagePickEnabled()
              ? () async {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                      _imageUrl = null;
                    });
                  }
                }
              : null,
          child: Text('Pick Image'),
        ),
        if (!_isImagePickEnabled())
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Try again next week.'), // Adjust the message
          ),
      ],
    );
  }

  bool _isImagePickEnabled() {
    if (_lastImagePickTime != null) {
      DateTime now = DateTime.now();
      DateTime nextEligiblePick = _lastImagePickTime!.add(Duration(days: 7));

      return now.isAfter(nextEligiblePick) &&
          (_lastDonationDate == null || _lastDonationDate!.isBefore(now));
    }

    return true;
  }
}
