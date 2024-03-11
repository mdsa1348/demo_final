// // ignore: file_names
// import 'package:demo/DemoHome.dart';
// import 'package:demo/ThemeSwitch.dart';
// import 'package:demo/blood/blood.dart';
// import 'package:demo/chatting/userid.dart';
// import 'package:demo/notification/main_notification/adminNotice.dart';
// import 'package:demo/profile/new.dart';
// import 'package:demo/Deseases_screen.dart';
// import 'package:demo/todo/todo_Page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AdminHomeScreen extends StatelessWidget {
//   const AdminHomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Screen'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications),
//             onPressed: () {
//               // Navigate to the notification page
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => NoticeBoard(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Container(
//           color: const Color.fromARGB(255, 250, 241, 160),
//           child: SecondScreen(
//             themeProvider: Provider.of<ThemeProviderNotifier>(context),showAppBar: false,
//           )),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.post_add),
//             label: 'Chats',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.menu),
//             label: 'Menu',
//           ),
//         ],
//         // Implement navigation logic here
//         onTap: (index) {
//           if (index == 1) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) =>
//                       const myUserListPage()), // Navigate to the SecondScreen
//             );
//           }

//           if (index == 2) {
//             // Show the settings overlay
//             showModalBottomSheet(
//               context: context,
//               builder: (context) {
//                 double screenWidth = MediaQuery.of(context).size.width;
//                 return SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.52,
//                   width: MediaQuery.of(context).size.width,
//                   child: SingleChildScrollView(
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.vertical,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           const SizedBox(
//                             height: 25,
//                           ),
//                           const Text(
//                             'Settings Page Content',
//                             style: TextStyle(fontSize: 20),
//                           ),
//                           const SizedBox(
//                             height: 30,
//                           ),
//                           // Create the first row with two buttons
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               SizedBox(
//                                 height: 80, // Set the height of the button
//                                 width: MediaQuery.of(context).size.width * 0.42,
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     // Implement action for the first button
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               TodoPage()), // Navigate to the SecondScreen
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                         255, 111, 29, 33), // Button color
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           12.0), // Border radius
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10.0,
//                                       horizontal: 20.0, // Padding
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'User Todo',
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 80, // Set the height of the button
//                                 width: MediaQuery.of(context).size.width * 0.42,
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     // Implement action for the first button
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               MyProfilePage()),
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                         255, 250, 60, 2), // Button color
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           12.0), // Border radius
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10.0,
//                                       horizontal: 20.0, // Padding
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'Profile',
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 30,
//                           ),
//                           // Create the first row with two buttons
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               SizedBox(
//                                 height: 80, // Set the height of the button
//                                 width: MediaQuery.of(context).size.width * 0.42,
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     // Implement action for the first button
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => BloodPage()),
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                         255, 250, 60, 2), // Button color
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           12.0), // Border radius
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10.0,
//                                       horizontal: 20.0, // Padding
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'Blood',
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 80, // Set the height of the button
//                                 width: MediaQuery.of(context).size.width * 0.42,
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     // Implement action for the first button
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => HomePage()),
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                         255, 111, 29, 33), // Button color
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           12.0), // Border radius
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10.0,
//                                       horizontal: 20.0, // Padding
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'HomePage',
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 16,
//                           ),
//                           // Create the second row with two buttons
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               SizedBox(
//                                 height: 80, // Set the height of the button
//                                 width: MediaQuery.of(context).size.width * 0.42,
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     // Implement action for the first button
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     minimumSize: Size(screenWidth * 0.4, 80),
//                                     backgroundColor: const Color.fromARGB(
//                                         255, 4, 95, 169), // Button color
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           12.0), // Border radius
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10.0,
//                                       horizontal: 20.0, // Padding
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'Button 3',
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 80, // Set the height of the button
//                                 width: MediaQuery.of(context).size.width * 0.42,
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     // Implement action for the first button
//                                     showDialog(
//                                         context: context,
//                                         builder: (context) => AlertDialog(
//                                               title: const Text("Logout?"),
//                                               content: const Text(
//                                                   "Are you sure u wanna logout?"),
//                                               actions: [
//                                                 ElevatedButton(
//                                                     style: ElevatedButton
//                                                         .styleFrom(
//                                                             backgroundColor:
//                                                                 Colors.red),
//                                                     onPressed: () {
//                                                       Navigator.pop(context);
//                                                     },
//                                                     child:
//                                                         const Text("Cancle")),
//                                                 ElevatedButton(
//                                                     onPressed: () async {
//                                                       // Perform the logout action
//                                                       await _signOut(context);
//                                                     },
//                                                     child:
//                                                         const Text("Confirm")),
//                                               ],
//                                             ));
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     minimumSize: Size(screenWidth * 0.4, 80),
//                                     backgroundColor: const Color.fromARGB(
//                                         255, 248, 195, 3), // Button color
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           12.0), // Border radius
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10.0,
//                                       horizontal: 20.0, // Padding
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'LogOut',
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               // Implement action for the TextButton
//                               Navigator.pop(context); // Close the overlay
//                             },
//                             child: const Text('Close'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }

//   Future<void> _signOut(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       // Navigate back to the authentication screen or any other desired screen
//       Navigator.pushReplacementNamed(
//           context, 'auth'); // Replace with your authentication screen route
//     } catch (e) {
//       print('Error signing out: $e');
//     }
//   }
// }
