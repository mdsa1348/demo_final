import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/medical/users/User_payment_page.dart';
import 'package:flutter/material.dart';

class Doctor {
  String name;
  String designation;
  String address;
  String hospital;
  String number;
  String gmail;
  String details;
  String speciality; // New field
  final String documentId; // New field to store the document ID

  Doctor({
    required this.name,
    required this.designation,
    required this.address,
    required this.hospital,
    required this.number,
    required this.gmail,
    required this.details,
    required this.speciality,
    required this.documentId, // Add the documentId to the constructor
  });
}

class AdminDoctorPage extends StatefulWidget {
  @override
  _AdminDoctorPageState createState() => _AdminDoctorPageState();
}

class _AdminDoctorPageState extends State<AdminDoctorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  final CollectionReference doctorsCollection =
      FirebaseFirestore.instance.collection('doctors');

  void _addDoctor() async {
    await doctorsCollection.add({
      'name': _nameController.text,
      'designation': _designationController.text,
      'address': _addressController.text,
      'hospital': _hospitalController.text,
      'number': _numberController.text,
      'gmail': _gmailController.text,
      'details': _detailsController.text,
      'speciality': _specialityController.text,
    });

    // Clear the text controllers after adding a doctor
    _nameController.clear();
    _designationController.clear();
    _specialityController.clear();
    _addressController.clear();
    _hospitalController.clear();
    _numberController.clear();
    _gmailController.clear();
    _detailsController.clear();

    // Refresh the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Page'),
      ),
      body: Container(
        color: Colors.grey,
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
            // Inside the StreamBuilder
            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index].data() as Map<String, dynamic>;

                // Check if the 'speciality' field exists and is not null
                String speciality = doctor['speciality'] ?? 'Not specified';

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
                                          color: Color.fromARGB(255, 65, 65, 65),
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
                                  price: 100.0,
                                ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show a dialog to enter doctor details
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Doctor'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                      TextField(
                        controller: _designationController,
                        decoration: InputDecoration(labelText: 'Designation'),
                      ),
                      TextField(
                        controller: _specialityController,
                        decoration: InputDecoration(labelText: 'Speciality'),
                      ),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(labelText: 'Address'),
                      ),
                      TextField(
                        controller: _hospitalController,
                        decoration: InputDecoration(labelText: 'Hospital'),
                      ),
                      TextField(
                        controller: _numberController,
                        decoration: InputDecoration(labelText: 'Number'),
                      ),
                      TextField(
                        controller: _gmailController,
                        decoration: InputDecoration(labelText: 'Gmail'),
                      ),
                      TextField(
                        controller: _detailsController,
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
                      _addDoctor();
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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
              _buildCard('Number', widget.doctor.number),
              _buildCard('Gmail', widget.doctor.gmail),
              _buildCard('Details', widget.doctor.details),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showEditDialog();
                    },
                    child: Text('Edit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.redAccent),
                    ),
                    child: Text('Delete'),
                  ),
                ],
              ),
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
                _deleteDoctor();
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

  void _deleteDoctor() async {
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctor.documentId)
        .delete();

    Navigator.of(context).pop();
  }
}
