import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAllUsersPage extends StatefulWidget {
  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AdminAllUsersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Users'),
      ),
      body: UsersList(),
    );
  }
}

class UsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        var users = snapshot.data!.docs;

        List<Widget> userWidgets = [];
        for (var user in users) {
          var userData = user.data() as Map<String, dynamic>;

          // Retrieve the user UID from Firebase Authentication
          String userUID = user.id ?? 'No UID';

          // Add a ListTile for each user
          userWidgets.add(
            ListTile(
              title: Text(userData['name'] ?? 'No Name'),
              subtitle: Text(userUID),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Delete the user account
                      print(userUID);
                      _deleteUserAccount(context, userUID);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.block),
                    onPressed: () {
                      // Disable the user account (Implement your logic here)
                      // You may want to update a field in Firestore to disable the account
                      updateDisabledStatus(userUID, true);
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          children: userWidgets,
        );
      },
    );
  }

  Future<void> _deleteUserAccount(BuildContext context, String userUID) async {
    print(userUID);

    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this user account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm deletion
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel deletion
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userUID)
            .delete();
        // User deleted successfully
      } catch (e) {
        print('Error deleting user account: $e');
        // Handle the error
      }
    }
  }

  Future<void> updateDisabledStatus(String uid, bool isDisabled) async {
    print(uid);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'disabled': isDisabled});

      // Fetch the updated user information after the update
      //User? updatedUser = await FirebaseAuth.instance.userChanges().first;

      // Log the updated user information
      //print('Successfully updated user: $updatedUser');
    } catch (error) {
      print('Error updating user: $error');
    }
  }
}
