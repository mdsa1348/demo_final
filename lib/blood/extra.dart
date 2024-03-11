import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BloodPage extends StatefulWidget {
  @override
  _BloodPageState createState() => _BloodPageState();
}

class _BloodPageState extends State<BloodPage> {
  late List<DocumentSnapshot> users = [];
  late TextEditingController searchController;
  String selectedOption = 'Sort by Name'; // Default option

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    getUsers().then((userList) {
      setState(() {
        users = userList;
      });
    });
  }

  Future<List<DocumentSnapshot>> getUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching users: $e');
      // Handle the error, show a snackbar, retry, or take appropriate action
      throw e; // Rethrow the error to propagate it to the calling function
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
          return nameA.compareTo(nameB);
        });
      } else if (option == 'Sort by Date') {
        // Assuming 'lastDate' is the field you want to sort by
        users.sort((a, b) {
          DateTime dateA = a['lastDate'].toDate();
          DateTime dateB = b['lastDate'].toDate();
          return dateA.compareTo(dateB);
        });
      }
      // Add more conditions for other sorting options if needed
    });
  }

  void showUserDetails(DocumentSnapshot user) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        var userData = user.data() as Map<String, dynamic>;
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User Data",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 5.0),
                UserDetailCard(
                  label: 'Name',
                  value: userData['name'],
                ),
                SizedBox(height: 10.0),
                UserDetailCard(
                  label: 'Blood Group',
                  value: userData['bloodGroup'],
                ),
                SizedBox(height: 10.0),
                UserDetailCard(
                  label: 'Address',
                  value: userData['address'],
                ),
                SizedBox(height: 10.0),
                UserDetailCard(
                  label: 'Last Donation Date',
                  value: userData['lastDonationDate'] != null
                      ? _formatTimestamp(userData['lastDonationDate'])
                      : 'N/A',
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    // Handle the blood donation request here
                    // You can implement the logic to send a request to the user
                    // For example, show a confirmation dialog or send a notification
                    // to the user that their request has been sent.
                    // Note: Implement the logic according to your application's requirements.
                  },
                  child: Text('Send Blood Donation Request'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Format the timestamp to display a readable date and time
    DateTime date = timestamp.toDate();
    return DateFormat.yMMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Page'),
      ),
      body: Container(
        color: Color.fromARGB(31, 0, 0, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            searchUsers('');
                          },
                        ),
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
                    items: <String>['Sort by Name', 'Sort by Date']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: users.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        var userData =
                            users[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () => showUserDetails(users[index]),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
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
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                value ?? 'N/A', // Display 'N/A' if the value is null
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
