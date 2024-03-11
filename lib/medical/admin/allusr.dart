// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AdminAllUsersPage extends StatefulWidget {
//   @override
//   _AllUsersPageState createState() => _AllUsersPageState();
// }
// // 
// class _AllUsersPageState extends State<AdminAllUsersPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('All Users'),
//       ),
//       body: UsersList(),
//     );
//   }
// }

// class UsersList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('users').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return CircularProgressIndicator();
//         }

//         var users = snapshot.data!.docs;

//         List<Widget> userWidgets = [];
//         for (var user in users) {
//           var userData = user.data() as Map<String, dynamic>;

//           // Retrieve the user UID from Firebase Authentication
//           String userUID = user.id ?? 'No UID';
//           print(userUID);
//           // Add a ListTile for each user
//           userWidgets.add(
//             ListTile(
//               title: Text(userData['name'] ?? 'No Name'),
//               subtitle: Text(userUID),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.delete),
//                     onPressed: () {
//                       // Delete the user account
//                       _deleteUserAccount(userUID);
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.block),
//                     onPressed: () {
//                       // Disable the user account (Implement your logic here)
//                       // You may want to update a field in Firestore to disable the account
//                       _disableUserAccount(userUID);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         return ListView(
//           children: userWidgets,
//         );
//       },
//     );
//   }

//   Future<void> _deleteUserAccount(String userUID) async {
//     print(userUID);
//     try {
//       User? user = await FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         await user.delete();
//         // User deleted successfully
//       } else {
//         // No user found
//       }
//     } catch (e) {
//       print('Error deleting user account: $e');
//       // Handle the error
//     }
//   }

//   Future<void> _disableUserAccount(String userUID) async {
//     try {
//       // Assuming you have a 'users' collection in Firestore
//       DocumentReference userDocRef =
//           FirebaseFirestore.instance.collection('users').doc(userUID);

//       // Set a field like 'isDisabled' to true to indicate the account is disabled
//       await userDocRef.update({'isDisabled': true});

//       // Optionally, you might also sign the user out if they are currently signed in
//       await FirebaseAuth.instance.signOut();

//       // Inform the user or take any other necessary actions
//       print('User account disabled successfully');
//     } catch (e) {
//       print('Error disabling user account: $e');
//       // Handle the error
//     }
//   }
// }
