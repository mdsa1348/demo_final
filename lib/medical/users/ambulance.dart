import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/ThemeSwitch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Ambulance {
  final String hospitalName;
  final String address;
  final String number;
  final String serviceTime;

  Ambulance({
    required this.hospitalName,
    required this.address,
    required this.number,
    required this.serviceTime,
  });
}

class userAmbulancePage extends StatefulWidget {
  @override
  _userAmbulancePageState createState() => _userAmbulancePageState();
}

class _userAmbulancePageState extends State<userAmbulancePage> {
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _serviceTimeController = TextEditingController();

  final CollectionReference ambulancesCollection =
      FirebaseFirestore.instance.collection('ambulances');

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Ambulance Page'),
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[700]
                : Colors.blue,
          ),
          body: Container(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900]
                : Colors.white,
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
                    final ambulance =
                        ambulances[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 44, 44, 44),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(
                            ambulance['hospitalName'],
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          subtitle: Text(
                            ambulance['address'],
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
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

class AmbulanceDetailsPage extends StatelessWidget {
  final Ambulance ambulance;

  const AmbulanceDetailsPage({required this.ambulance});

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
              _buildCard('Hospital Name', ambulance.hospitalName),
              _buildCard('Address', ambulance.address),
              _buildCard('Number', ambulance.number, isPhoneNumber: true),
              _buildCard('Service Time', ambulance.serviceTime),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, String content,
      {bool isPhoneNumber = false}) {
    return GestureDetector(
      onTap: () async {
        if (isPhoneNumber) {
          final phoneNumber = ambulance.number;
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
}
