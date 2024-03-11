import 'package:demo/Extra.dart';
import 'package:demo/ThemeSwitch.dart';
import 'package:demo/medical/users/User_payment_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Doctor {
  String name;
  String designation;
  String address;
  String hospital;
  String number;
  String gmail;
  String details;
  String speciality; // New field
  final String documentId;

  Doctor({
    required this.name,
    required this.designation,
    required this.address,
    required this.hospital,
    required this.number,
    required this.gmail,
    required this.details,
    required this.speciality,
    required this.documentId,
  });
}

class userDoctorPage extends StatefulWidget {
  @override
  _userDoctorPageState createState() => _userDoctorPageState();
}

class _userDoctorPageState extends State<userDoctorPage> {
  final CollectionReference doctorsCollection =
      FirebaseFirestore.instance.collection('doctors');

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Doctor's Page"),
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[700] // Dark theme background color
                : Colors.blue, // Light theme background color
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(Icons.notification_important),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoadingButtonPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.themeMode == ThemeMode.dark
                  ? null
                  : LinearGradient(
                      colors: [
                        Color.fromRGBO(181, 207, 193, 1),
                        Color.fromARGB(255, 80, 96, 116),
                        Color.fromARGB(255, 145, 217, 195)
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
                // Add a search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      // Handle search functionality here
                      // You can use the query to get the updated search text
                      // Perform search logic here
                      // Example: searchDoctors(query);
                      setState(
                          () {}); // Trigger a rebuild to update the displayed list
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for doctors...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: doctorsCollection.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      // if (snapshot.connectionState == ConnectionState.waiting) {
                      //   return CircularProgressIndicator();
                      // }

                      // Display the list of doctors
                      final doctors = snapshot.data?.docs ?? [];

                      // Filter doctors based on search query
                      final filteredDoctors = doctors.where((doctor) {
                        final doctorData =
                            doctor.data() as Map<String, dynamic>;
                        final doctorName = doctorData['name'].toLowerCase();
                        final speciality =
                            doctorData['speciality']?.toLowerCase() ??
                                "Unknown";
                        final address = doctorData['address'].toLowerCase();
                        final hospital = doctorData['hospital'].toLowerCase();
                        final searchQuery =
                            _searchController.text.toLowerCase();

                        return doctorName.contains(searchQuery) ||
                            speciality.contains(searchQuery) ||
                            address.contains(searchQuery) ||
                            hospital.contains(searchQuery);
                      }).toList();
                      // Inside the StreamBuilder
                      return ListView.builder(
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = filteredDoctors[index].data()
                              as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text(
                                  doctor['name'],
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor['designation'],
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: const Color.fromARGB(
                                              255, 48, 48, 48)),
                                    ),
                                    Text(
                                      doctor['speciality'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 65, 65, 65),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<int>(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 0,
                                      child: Text('Option 1'),
                                    ),
                                    PopupMenuItem(
                                      value: 1,
                                      child: Text('Book the Doctor'),
                                    ),
                                    // Add more options as needed
                                  ],
                                  onSelected: (value) async {
                                    // Handle option selection here
                                    if (value == 0) {
                                      // Option 1
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => GPayPage(
                                      //       paymentItems: [
                                      //         // PaymentItem(
                                      //         //   label: 'Total',
                                      //         //   amount: '99.99',
                                      //         //   status: PaymentItemStatus.final_price,
                                      //         // ),
                                      //         // Add more PaymentItem instances as needed
                                      //       ],
                                      //     ),
                                      //   ),
                                      // );
                                    } else if (value == 1) {
                                      // Option 2
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserPaymentPage(
                                              price:
                                                  100.0), // Replace 100.0 with the actual price
                                        ),
                                      );
                                    }
                                    // Add more cases as needed
                                  },
                                ),
                                onTap: () {
                                  // Show detailed information in a bottom sheet
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return DoctorDetailsPage(
                                        doctor: Doctor(
                                          name: doctor['name'],
                                          designation: doctor['designation'],
                                          speciality: doctor['speciality'],
                                          address: doctor['address'],
                                          hospital: doctor['hospital'],
                                          number: doctor['number'],
                                          gmail: doctor['gmail'],
                                          details: doctor['details'],
                                          documentId: doctors[index].id,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
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
}

class DoctorDetailsPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailsPage({required this.doctor});

  @override
  _DoctorDetailsPageState createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editDesignationController =
      TextEditingController();
  final TextEditingController _editSpecialityController =
      TextEditingController();
  final TextEditingController _editAddressController = TextEditingController();
  final TextEditingController _editHospitalController = TextEditingController();
  final TextEditingController _editNumberController = TextEditingController();
  final TextEditingController _editGmailController = TextEditingController();
  final TextEditingController _editDetailsController = TextEditingController();

  late FirebaseAuth _auth;
  late User? user;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    user = _auth.currentUser;

    // Assuming you have a 'users' collection in Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get()
        .then((userData) {
      final email = userData['email'] as String?;
      setState(() {
        currentUserEmail = email ?? null;
      });
    }).catchError((error) {
      print('Error fetching user data: $error');
    });
  }

  void _initializeControllers() {
    _editNameController.text = widget.doctor.name;
    _editDesignationController.text = widget.doctor.designation;
    _editSpecialityController.text = widget.doctor.speciality;
    _editAddressController.text = widget.doctor.address;
    _editHospitalController.text = widget.doctor.hospital;
    _editNumberController.text = widget.doctor.number;
    _editGmailController.text = widget.doctor.gmail;
    _editDetailsController.text = widget.doctor.details;
  }

  @override
  Widget build(BuildContext context) {
    // if (currentUserEmail == null) {
    //   // Return a loading indicator or handle the case where email is not yet initialized
    //   return CircularProgressIndicator();
    // }

    print(widget.doctor.gmail);
    print(currentUserEmail);
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Details'),
      ),
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height * 0.8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard('Name', widget.doctor.name),
              _buildCard('Designation', widget.doctor.designation),
              _buildCard('Speciality', widget.doctor.speciality),
              _buildCard('Address', widget.doctor.address),
              _buildCard('Hospital', widget.doctor.hospital),
              _buildsCard('Number', widget.doctor.number, isPhoneNumber: true),
              _buildCard('Gmail', widget.doctor.gmail),
              _buildCard('Details', widget.doctor.details),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.doctor.gmail == currentUserEmail)
                    ElevatedButton(
                      onPressed: () {
                        print(currentUserEmail);
                        _showEditDialog();
                      },
                      child: Text('Edit'),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      _showEditDialog();
                    },
                    child: Text('Add to Cart'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Doctor Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _editNameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _editDesignationController,
                  decoration: InputDecoration(labelText: 'Designation'),
                ),
                TextField(
                  controller: _editSpecialityController,
                  decoration: InputDecoration(labelText: 'Speciality'),
                ),
                TextField(
                  controller: _editAddressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: _editHospitalController,
                  decoration: InputDecoration(labelText: 'Hospital'),
                ),
                TextField(
                  controller: _editNumberController,
                  decoration: InputDecoration(labelText: 'Number'),
                ),
                TextField(
                  controller: _editGmailController,
                  decoration: InputDecoration(labelText: 'Gmail'),
                ),
                TextField(
                  controller: _editDetailsController,
                  decoration: InputDecoration(labelText: 'Details'),
                ),
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
            ElevatedButton(
              onPressed: () {
                _updateDoctorDetails();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateDoctorDetails() async {
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctor.documentId)
        .update({
      'name': _editNameController.text,
      'designation': _editDesignationController.text,
      'speciality': _editSpecialityController.text,
      'address': _editAddressController.text,
      'hospital': _editHospitalController.text,
      'number': _editNumberController.text,
      'gmail': _editGmailController.text,
      'details': _editDetailsController.text,
    });

    setState(() {
      widget.doctor.name = _editNameController.text;
      widget.doctor.designation = _editDesignationController.text;
      widget.doctor.speciality = _editSpecialityController.text;
      widget.doctor.address = _editAddressController.text;
      widget.doctor.hospital = _editHospitalController.text;
      widget.doctor.number = _editNumberController.text;
      widget.doctor.gmail = _editGmailController.text;
      widget.doctor.details = _editDetailsController.text;
    });
  }

  Widget _buildsCard(String title, String content,
      {bool isPhoneNumber = false}) {
    return GestureDetector(
      onTap: () async {
        if (isPhoneNumber) {
          final phoneNumber = widget.doctor.number;
          try {
            launch("tel:$phoneNumber");
          } catch (e) {
            print('Error launching phone call: $e');
          }
        }
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              isPhoneNumber
                  ? Text(
                      content,
                      style: TextStyle(
                        color: Colors.blue, // Customize color as needed
                        fontSize: 16,
                      ),
                    )
                  : Text(content),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, String content) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
