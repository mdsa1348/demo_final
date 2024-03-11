import 'package:demo/ThemeSwitch.dart';
import 'package:demo/notification/blood_notification/notification_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BloodPage extends StatefulWidget {
  @override
  _BloodPageState createState() => _BloodPageState();
}

class _BloodPageState extends State<BloodPage> {
  String? currentUserName;

  late List<DocumentSnapshot> users = [];
  late TextEditingController searchController;
  String selectedOption = 'Sort by Name';
  List<Map<String, dynamic>> bloodDonationRequests = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    fetchCurrentUserName();
    getUsers().then((userList) {
      setState(() {
        users = userList;
      });
    });
  }

  Future<void> fetchCurrentUserName() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot snapshot =
            await _firestore.collection('users').doc(currentUser.uid).get();

        setState(() {
          currentUserName = snapshot.get('name');
        });
      }
    } catch (e) {
      print('Error fetching current user name: $e');
    }
  }

  Future<List<DocumentSnapshot>> getUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching users: $e');
      throw e;
    }
  }

  void searchUsers(String query) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<DocumentSnapshot> allUsers = querySnapshot.docs;

    List<DocumentSnapshot> filteredUsers = allUsers.where((user) {
      var userData = user.data() as Map<String, dynamic>;
      return userData['name'].toLowerCase().contains(query.toLowerCase()) ||
          userData['address'].toLowerCase().contains(query.toLowerCase()) ||
          userData['bloodGroup'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    filteredUsers.sort((a, b) {
      var nameA = a['name'].toLowerCase();
      var nameB = b['name'].toLowerCase();
      return nameA.compareTo(nameB);
    });

    setState(() {
      users = filteredUsers;
    });
  }

  void handleSortOption(String option) {
    setState(() {
      selectedOption = option;
      if (option == 'Sort by Name') {
        users.sort((a, b) {
          var nameA = a['name'].toLowerCase();
          var nameB = b['name'].toLowerCase();
          print(
              'Name A: $nameA, Last Donation Date A: ${a['lastDonationDate']}');
          print(
              'Name B: $nameB, Last Donation Date B: ${b['lastDonationDate']}');
          return nameA.compareTo(nameB);
        });
      } else if (option == 'Sort by Date') {
        users.sort((a, b) {
          try {
            // Check if both users have the 'lastDonationDate' field
            if (a['lastDonationDate'] != null &&
                b['lastDonationDate'] != null) {
              DateTime dateA =
                  a['lastDonationDate']?.toDate() ?? DateTime(1970);
              DateTime dateB =
                  b['lastDonationDate']?.toDate() ?? DateTime(1970);

              print(
                  'Date A: $dateA, Last Donation Date A: ${a['lastDonationDate']}');
              print(
                  'Date B: $dateB, Last Donation Date B: ${b['lastDonationDate']}');

              // Calculate the difference in months
              int monthsDifferenceA =
                  _calculateMonthsDifference(dateA, DateTime.now());
              int monthsDifferenceB =
                  _calculateMonthsDifference(dateB, DateTime.now());

              // Sort in descending order based on the difference
              // Sort in ascending order based on the difference
              return monthsDifferenceA.compareTo(monthsDifferenceB);
            } else {
              return 0; // One or both users don't have the 'lastDonationDate' field
            }
          } catch (e) {
            print('Error sorting by date: $e');
            return 0; // Handle error, return 0 for equality
          }
        });
      }
    });
  }

  int _calculateMonthsDifference(DateTime dateA, DateTime dateB) {
    return (dateA.year - dateB.year) * 12 + dateA.month - dateB.month;
  }

  Future<String?> getUserNumberFromFirestore(String? userId) async {
    if (userId == null) {
      return null;
    }

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        // Assuming the number is stored in a field called 'number'
        return userSnapshot['number'];
      } else {
        return null; // User document does not exist
      }
    } catch (e) {
      print('Error getting user number: $e');
      return null;
    }
  }

  void showUserDetails(
    DocumentSnapshot user,
    BuildContext Function() getContext,
  ) async {
    try {
      var userData = user.data() as Map<String, dynamic>;

      User? THEcurrentUser = _auth.currentUser;
      String? requesterId = THEcurrentUser?.uid;
      String status = "Pending";
      // Get the current user's name
      String? requesterName =
          await getUserName(_auth.currentUser!.uid) ?? 'Unknown User';
      String? requesterNum =
          await getUserNumberFromFirestore(requesterId) ?? 'Unknown User';
      // Ensure that the BottomSheet is shown only when the username is fetched
      if (requesterName != null) {
        showModalBottomSheet(
          context: getContext(),
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "User Data",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5.0),
                    UserDetailCard(
                      label: 'Name',
                      value: userData['name'],
                    ),
                    const SizedBox(height: 10.0),
                    UserDetailCard(
                      label: 'Blood Group',
                      value: userData['bloodGroup'],
                    ),
                    const SizedBox(height: 10.0),
                    UserDetailCard(
                      label: 'Address',
                      value: userData['address'],
                    ),
                    const SizedBox(height: 10.0),
                    UserDetailCard(
                      label: 'Last Donation Date',
                      value: userData['lastDonationDate'] != null
                          ? _formatTimestamp(userData['lastDonationDate'])
                          : 'N/A',
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          print(
                              'Sending blood donation request from: $requesterName');

                          // Check if the request already exists in Firebase
                          QuerySnapshot existingRequests =
                              await FirebaseFirestore
                                  .instance
                                  .collection('notifications')
                                  .where('requesterid', isEqualTo: requesterId)
                                  .where('recipient',
                                      isEqualTo: userData['name'])
                                  .get();

                          if (existingRequests.docs.isNotEmpty) {
                            // Request already exists, show a snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'You already sent a request to ${userData['name']}'),
                              ),
                            );
                          } else {
                            // Request doesn't exist, send the data to Firebase
                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .add({
                              'requesterid': requesterId,
                              'requester': requesterName,
                              'requesterNum': requesterNum,
                              'recipient': userData['name'],
                              'number': userData['number'],
                              'status': "pending",
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                            // Close the bottom sheet
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          print('Error sending blood donation request: $e');
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue), // Set your desired background color
                        minimumSize: MaterialStateProperty.all<Size>(Size(
                            MediaQuery.of(context).size.width,
                            60)), // Set width and height
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20), // Adjust padding as needed
                        ),
                      ),
                      child: const Text(
                        'Send Blood Donation Request',
                        style: TextStyle(
                            fontSize: 16), // Adjust text style as needed
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      } else {
        // Handle the case where username is not fetched
        print('Error: Could not fetch username.');
      }
    } catch (e) {
      print('Error showing user details: $e');
    }
  }

  Future<String?> getUserName(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();
      return userSnapshot['name'] as String?;
    } catch (e) {
      print('Error fetching user name: $e');
      return null;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat.yMMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                StreamBuilder<User?>(
                  stream: _auth.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Users');
                    }

                    final User? currentUser = snapshot.data;

                    if (currentUser != null) {
                      return StreamBuilder<DocumentSnapshot>(
                        stream: _firestore
                            .collection('users')
                            .doc(currentUser.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Users');
                          }

                          try {
                            final String currentUserName =
                                snapshot.data?.get('name') as String? ??
                                    'Users';
                            return Text(currentUserName);
                          } catch (e) {
                            print('Error getting current user name: $e');
                            return const Text('Users');
                          }
                        },
                      );
                    } else {
                      return const Text('Users');
                    }
                  },
                ),
                const SizedBox(width: 8),
                const Text("Blood Page"),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bloodtype_outlined),
                onPressed: navigateToNotificationPage,
              ),
            ],
          ),
          body: Container(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900]
                : Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Colors.grey[900]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              searchUsers(value);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search by name or blood group',
                              hintStyle: TextStyle(
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? Colors.grey[500]
                                    : Colors.grey[700],
                              ),
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.grey),
                              suffixIcon: IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  searchController.clear();
                                  searchUsers('');
                                },
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedOption,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              handleSortOption(newValue);
                            }
                          },
                          style: TextStyle(
                            color: Colors.black, // Set text color to black
                          ),
                          items: <String>['Sort by Name', 'Sort by Date']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 124, 124,
                                      124), // Set text color to black
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: users.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            var userData =
                                users[index].data() as Map<String, dynamic>;
                            return GestureDetector(
                              onTap: () =>
                                  showUserDetails(users[index], () => context),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0, left: 10.0, right: 10.0),
                                child: Card(
                                  elevation: 4.0,
                                  child: ListTile(
                                    title: Text(userData['name']),
                                    subtitle: Text(userData['address']),
                                  ),
                                ),
                              ),
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

  void navigateToNotificationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationPage(),
      ),
    );
  }
}

class UserDetailCard extends StatelessWidget {
  final String label;
  final String? value;

  UserDetailCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              if (value != null)
                Text(
                  value!,
                  style: const TextStyle(fontSize: 18.0),
                )
              else
                Text(
                  'N/A',
                  style: const TextStyle(fontSize: 18.0),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
