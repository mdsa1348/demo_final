import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class Ambulance {
  late final String hospitalName;
  late final String documentId;
  late final String address;
  late final String number;
  late final String serviceTime;

  Ambulance({
    required this.hospitalName,
    required this.documentId,
    required this.address,
    required this.number,
    required this.serviceTime,
  });
}

class AdminAmbulancePage extends StatefulWidget {
  @override
  _AdminAmbulancePageState createState() => _AdminAmbulancePageState();
}

class _AdminAmbulancePageState extends State<AdminAmbulancePage> {
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _serviceTimeController = TextEditingController();

  final CollectionReference ambulancesCollection =
      FirebaseFirestore.instance.collection('ambulances');

  void _addAmbulance() async {
    await ambulancesCollection.add({
      'hospitalName': _hospitalNameController.text,
      'address': _addressController.text,
      'number': _numberController.text,
      'serviceTime': _serviceTimeController.text,
    });

    // Clear the text controllers after adding an ambulance
    _hospitalNameController.clear();
    _addressController.clear();
    _numberController.clear();
    _serviceTimeController.clear();

    // Refresh the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ambulance Page'),
      ),
      body: Container(
        color: Colors.grey,
        child: StreamBuilder<QuerySnapshot>(
          stream: ambulancesCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            // Display the list of ambulances
            final ambulances = snapshot.data?.docs ?? [];
            return ListView.builder(
              itemCount: ambulances.length,
              itemBuilder: (context, index) {
                final ambulance = ambulances[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text(ambulance['hospitalName']),
                      subtitle: Text(ambulance['address']),
                      onTap: () {
                        // Show detailed information in a bottom sheet
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return AmbulanceDetailsPage(
                              ambulance: Ambulance(
                                hospitalName: ambulance['hospitalName'],
                                address: ambulance['address'],
                                number: ambulance['number'],
                                serviceTime: ambulance['serviceTime'],
                                documentId: ambulances[index].id, // Add this line
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
        )

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show a dialog to enter ambulance details
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Ambulance'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _hospitalNameController,
                        decoration: InputDecoration(labelText: 'Hospital Name'),
                      ),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(labelText: 'Address'),
                      ),
                      TextField(
                        controller: _numberController,
                        decoration: InputDecoration(labelText: 'Number'),
                      ),
                      TextField(
                        controller: _serviceTimeController,
                        decoration: InputDecoration(labelText: 'Service Time'),
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
                      _addAmbulance();
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

class AmbulanceDetailsPage extends StatefulWidget {
  final Ambulance ambulance;

  const AmbulanceDetailsPage({required this.ambulance});

  @override
  _AmbulanceDetailsPageState createState() => _AmbulanceDetailsPageState();
}

class _AmbulanceDetailsPageState extends State<AmbulanceDetailsPage> {
  final TextEditingController _editHospitalNameController =
  TextEditingController();
  final TextEditingController _editAddressController = TextEditingController();
  final TextEditingController _editNumberController = TextEditingController();
  final TextEditingController _editServiceTimeController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ambulance Details'),
      ),
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height * 0.8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard('Hospital Name', widget.ambulance.hospitalName),
              _buildCard('Address', widget.ambulance.address),
              _buildCard('Number', widget.ambulance.number),
              _buildCard('Service Time', widget.ambulance.serviceTime),
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
          title: Text('Edit Ambulance Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _editHospitalNameController
                    ..text = widget.ambulance.hospitalName,
                  decoration: InputDecoration(labelText: 'Hospital Name'),
                ),
                TextField(
                  controller: _editAddressController
                    ..text = widget.ambulance.address,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: _editNumberController
                    ..text = widget.ambulance.number,
                  decoration: InputDecoration(labelText: 'Number'),
                ),
                TextField(
                  controller: _editServiceTimeController
                    ..text = widget.ambulance.serviceTime,
                  decoration: InputDecoration(labelText: 'Service Time'),
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
                _updateAmbulanceDetails();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateAmbulanceDetails() async {
    // Update details in Firestore
    await FirebaseFirestore.instance
        .collection('ambulances')
        .doc(widget.ambulance.documentId) // Add a documentId property to Ambulance class
        .update({
      'hospitalName': _editHospitalNameController.text,
      'address': _editAddressController.text,
      'number': _editNumberController.text,
      'serviceTime': _editServiceTimeController.text,
    });

    // Refresh UI
    setState(() {
      // Update widget.ambulance with new details
      widget.ambulance.hospitalName = _editHospitalNameController.text;
      widget.ambulance.address = _editAddressController.text;
      widget.ambulance.number = _editNumberController.text;
      widget.ambulance.serviceTime = _editServiceTimeController.text;
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this ambulance?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAmbulance();
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

  void _deleteAmbulance() async {
    // Delete document from Firestore
    await FirebaseFirestore.instance
        .collection('ambulances')
        .doc(widget.ambulance.documentId) // Add a documentId property to Ambulance class
        .delete();

    // Navigate back to the previous screen
    Navigator.of(context).pop();
  }
}
