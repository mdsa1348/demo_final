import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Hospital {
  late final String name;
  late final String documentId;
  late final String location;
  late final String establishedIn;
  late final String rating;

  Hospital({
    required this.name,
    required this.documentId,
    required this.location,
    required this.establishedIn,
    required this.rating,
  });
}

class AdminHospitalPage extends StatefulWidget {
  @override
  _AdminHospitalPageState createState() => _AdminHospitalPageState();
}

class _AdminHospitalPageState extends State<AdminHospitalPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _establishedInController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  final CollectionReference hospitalsCollection =
  FirebaseFirestore.instance.collection('hospitals');

  void _addHospital() async {
    await hospitalsCollection.add({
      'name': _nameController.text,
      'location': _locationController.text,
      'establishedIn': _establishedInController.text,
      'rating': _ratingController.text,
    });

    // Clear the text controllers after adding a hospital
    _nameController.clear();
    _locationController.clear();
    _establishedInController.clear();
    _ratingController.clear();

    // Refresh the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Page'),
      ),
      body: Container(
        color: Colors.grey,
        child: StreamBuilder<QuerySnapshot>(
          stream: hospitalsCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            // Display the list of hospitals
            final hospitals = snapshot.data?.docs ?? [];
            return ListView.builder(
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                final hospital = hospitals[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text(hospital['name']),
                      subtitle: Text(hospital['location']),
                      onTap: () {
                        // Show detailed information in a bottom sheet
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return HospitalDetailsPage(
                              hospital: Hospital(
                                name: hospital['name'],
                                location: hospital['location'],
                                establishedIn: hospital['establishedIn'],
                                rating: hospital['rating'],
                                documentId: hospitals[index].id, // Add this line
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
          // Show a dialog to enter hospital details
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Hospital'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Hospital Name'),
                      ),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(labelText: 'Location'),
                      ),
                      TextField(
                        controller: _establishedInController,
                        decoration: InputDecoration(labelText: 'Established In'),
                      ),
                      TextField(
                        controller: _ratingController,
                        decoration: InputDecoration(labelText: 'Rating'),
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
                      _addHospital();
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

class HospitalDetailsPage extends StatefulWidget {
  final Hospital hospital;

  const HospitalDetailsPage({required this.hospital});

  @override
  _HospitalDetailsPageState createState() => _HospitalDetailsPageState();
}

class _HospitalDetailsPageState extends State<HospitalDetailsPage> {
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editLocationController = TextEditingController();
  final TextEditingController _editEstablishedInController =
  TextEditingController();
  final TextEditingController _editRatingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _editNameController.text = widget.hospital.name;
    _editLocationController.text = widget.hospital.location;
    _editEstablishedInController.text = widget.hospital.establishedIn;
    _editRatingController.text = widget.hospital.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Details'),
      ),
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height * 0.8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard('Hospital Name', widget.hospital.name),
              _buildCard('Location', widget.hospital.location),
              _buildCard('Established In', widget.hospital.establishedIn),
              _buildCard('Rating', widget.hospital.rating),
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
          title: Text('Edit Hospital Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _editNameController,
                  decoration: InputDecoration(labelText: 'Hospital Name'),
                ),
                TextField(
                  controller: _editLocationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: _editEstablishedInController,
                  decoration: InputDecoration(labelText: 'Established In'),
                ),
                TextField(
                  controller: _editRatingController,
                  decoration: InputDecoration(labelText: 'Rating'),
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
                _updateHospitalDetails();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateHospitalDetails() async {
    await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(widget.hospital.documentId)
        .update({
      'name': _editNameController.text,
      'location': _editLocationController.text,
      'establishedIn': _editEstablishedInController.text,
      'rating': _editRatingController.text,
    });

    setState(() {
      widget.hospital.name = _editNameController.text;
      widget.hospital.location = _editLocationController.text;
      widget.hospital.establishedIn = _editEstablishedInController.text;
      widget.hospital.rating = _editRatingController.text;
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this hospital?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteHospital();
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

  void _deleteHospital() async {
    await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(widget.hospital.documentId)
        .delete();

    Navigator.of(context).pop();
  }
}
