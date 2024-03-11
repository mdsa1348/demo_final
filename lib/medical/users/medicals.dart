import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/ThemeSwitch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Hospital {
  final String name;
  final String location;
  final String establishedIn;
  final String rating;

  Hospital({
    required this.name,
    required this.location,
    required this.establishedIn,
    required this.rating,
  });
}

class userHospitalPage extends StatefulWidget {
  @override
  _userHospitalPageState createState() => _userHospitalPageState();
}

class _userHospitalPageState extends State<userHospitalPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _establishedInController =
      TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  final CollectionReference hospitalsCollection =
      FirebaseFirestore.instance.collection('hospitals');

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Hospital Page'),
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[700] // Dark theme background color
                : Colors.blue, // Light theme background color
          ),
          body: Container(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900]
                : Colors.white,
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
                    final hospital =
                        hospitals[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? Colors.white
                              : Colors.grey[900],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(
                            hospital['name'],
                            style: TextStyle(
                              fontSize: 20,
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? const Color.fromARGB(
                                      255, 0, 0, 0) // Text color for dark theme
                                  : const Color.fromARGB(255, 255, 255,
                                      255), // Text color for light theme
                            ),
                          ),
                          
                          subtitle: Text(
                            hospital['location'],
                            style: TextStyle(
                              fontSize: 18,
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? const Color.fromARGB(
                                      255, 0, 0, 0) // Text color for dark theme
                                  : const Color.fromARGB(255, 255, 255,
                                      255), // Text color for light theme
                            ),
                          ),
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
        );
      },
    );
  }
}

class HospitalDetailsPage extends StatelessWidget {
  final Hospital hospital;

  const HospitalDetailsPage({required this.hospital});

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
              _buildCard('Name', hospital.name),
              _buildCard('Location', hospital.location),
              _buildCard('Established In', hospital.establishedIn),
              _buildCard('Rating', hospital.rating),
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
