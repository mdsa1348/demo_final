// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/DemoHome.dart';
import 'package:demo/ThemeSwitch.dart';
import 'package:demo/blood/blood.dart';
import 'package:demo/bmi/bmi.dart';
import 'package:demo/chatting/chat.dart';
import 'package:demo/chatting/userid.dart';
import 'package:demo/medical/users/ambulance.dart';
import 'package:demo/medical/users/doctor.dart';
import 'package:demo/medical/users/medicals.dart';
import 'package:demo/notification/blood_notification/important.dart';
import 'package:demo/notification/main_notification/usersnotice.dart';
import 'package:demo/profile/new.dart';
import 'package:demo/Deseases_screen.dart';
import 'package:demo/todo/todo_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool showBottomNavigationBar;
  late PageController _pageController;
  bool showAppBar = true;

  void toggleAppBarVisibility() {
    setState(() {
      showAppBar = !showAppBar;
    });
  }

  @override
  void initState() {
    super.initState();
    showBottomNavigationBar = true;
    _pageController = PageController();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Your code that modifies state or triggers build after the frame is built
      checkUserNameAndShowPopup(context);
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   // Check and show pop-up card if needed
  //   checkUserNameAndShowPopup(_auth.currentUser, context);
  // }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Future<void> checkUserNameAndShowPopup(
  //     User? currentUser, BuildContext context) async {
  //   if (currentUser != null &&
  //       (currentUser.displayName == null || currentUser.displayName!.isEmpty)) {
  //     print("Display name is either null or empty");
  //     await showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           backgroundColor: Colors.red, // Set the background color here
  //           title: Text(
  //             "Super Important",
  //             style: TextStyle(fontSize: 22),
  //           ),
  //           content: Text(
  //             "Please set your Profile before proceeding.",
  //             style: TextStyle(fontSize: 18),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 // Navigate to the screen where the user can set their name
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => MyProfilePage()),
  //                 );
  //               },
  //               child: Text("OK"),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   } else {
  //     print(
  //         "Display name is not null and not empty: ${currentUser?.displayName}");
  //   }
  // }

  void checkUserNameAndShowPopup(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      // Reference to the user's document in Firestore
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      // Get the user's document
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // Check if the document exists
        String? userName = userDoc.get('name');

        if (userName != null && userName.isNotEmpty) {
          // Retrieve the "name" field from the document data
          print("userName : $userName");
          // Directly navigate to another screen if the user's name is found
        } else {
          // Show the pop-up card if the user's name is not found
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.red, // Set the background color here
                title: Text(
                  "Super Important",
                  style: TextStyle(fontSize: 22),
                ),
                content: Text(
                  "Please set your Profile before proceeding.",
                  style: TextStyle(fontSize: 18),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyProfilePage(),
                        ),
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('User document does not exist');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.red, // Set the background color here
              title: Text(
                "Super Important",
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                "Please set your Profile before proceeding.",
                style: TextStyle(fontSize: 18),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyProfilePage(),
                      ),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      print('No user signed in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        bool showBottomNavigationBar = true;

        // Check and show pop-up card if needed
        //checkUserNameAndShowPopup(_auth.currentUser, context);

        return Scaffold(
          //appBar: showAppBar ? AppBar(title: Text('My App')) : null,
          appBar: showAppBar
              ? AppBar(
                  backgroundColor: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.grey[700] // Dark theme background color
                      : Colors.white,
                  title: GestureDetector(
                    onTap: () async {
                      // Check if the current user's email is "admin@gmail.com"
                      User? currentUser = _auth.currentUser;
                      if (currentUser != null &&
                          currentUser.email == "admin@gmail.com") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImportantPage(),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Home Screen',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  actions: [
                    Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (_) {
                        themeProvider.toggleTheme();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      color: Colors.black,
                      onPressed: () {
                        // Navigate to the notification page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => userNoticeBoard(),
                          ),
                        );
                      },
                    ),
                  ],
                )
              : null,
          body: Container(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900] // Dark theme background color
                : const Color.fromARGB(
                    255, 220, 219, 219), // Light theme background color
            child: SecondScreen(
              themeProvider: Provider.of<ThemeProviderNotifier>(context),
              toggleAppBar: toggleAppBarVisibility,
            ),
          ),
          bottomNavigationBar: Visibility(
            visible: showBottomNavigationBar,
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.post_add),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Menu',
                ),
              ],
              backgroundColor: themeProvider.themeMode == ThemeMode.dark
                  ? const Color.fromARGB(255, 33, 33, 33) // Dark mode color
                  : const Color.fromARGB(
                      255, 251, 250, 250), // Light mode color
              selectedItemColor: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.white // Dark mode selected item color
                  : Colors.black, // Light mode selected item color
              unselectedItemColor: themeProvider.themeMode == ThemeMode.dark
                  ? const Color.fromARGB(
                      255, 130, 129, 129) // Dark mode unselected item color
                  : const Color.fromARGB(
                      255, 54, 54, 54), // Light mode unselected item color
              // Implement navigation logic here
              onTap: (index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DemoChats(
                        themeProvider:
                            Provider.of<ThemeProviderNotifier>(context),
                      ),
                    ),
                  ).then((_) {
                    // Set showBottomNavigationBar to true after returning from DemoChats
                    setState(() {
                      showBottomNavigationBar = true;
                    });
                  });
                }

                if (index == 2) {
                  // Show the settings overlay
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      double screenWidth = MediaQuery.of(context).size.width;
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.60,
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? const Color.fromARGB(255, 62, 62, 62)
                                  : const Color.fromARGB(255, 198, 197, 197),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  const Text(
                                    'Settings Page Content',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  // Create the first row with two buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height:
                                            80, // Set the height of the button
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Implement action for the first button
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TodoPage()), // Navigate to the SecondScreen
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(255, 111,
                                                    29, 33), // Button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12.0), // Border radius
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 20.0, // Padding
                                            ),
                                          ),
                                          child: const Text(
                                            'User Todo',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            80, // Set the height of the button
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Implement action for the first button
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyProfilePage()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(255, 250,
                                                    60, 2), // Button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12.0), // Border radius
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 20.0, // Padding
                                            ),
                                          ),
                                          child: const Text(
                                            'Profile',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  // Create the first row with two buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height:
                                            80, // Set the height of the button
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Implement action for the first button
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BloodPage()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(255, 250,
                                                    60, 2), // Button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12.0), // Border radius
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 20.0, // Padding
                                            ),
                                          ),
                                          child: const Text(
                                            'Blood',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            80, // Set the height of the button
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Implement action for the first button
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      userDoctorPage()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(255, 111,
                                                    29, 33), // Button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12.0), // Border radius
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 20.0, // Padding
                                            ),
                                          ),
                                          child: const Text(
                                            'Doctors',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height:
                                            80, // Set the height of the button
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Implement action for the first button
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      userHospitalPage()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            minimumSize:
                                                Size(screenWidth * 0.4, 80),
                                            backgroundColor:
                                                const Color.fromARGB(255, 85,
                                                    78, 51), // Button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12.0), // Border radius
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 20.0, // Padding
                                            ),
                                          ),
                                          child: const Text(
                                            'Medicals',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            80, // Set the height of the button
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Implement action for the first button
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      userAmbulancePage()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(255, 4, 95,
                                                    169), // Button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12.0), // Border radius
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 20.0, // Padding
                                            ),
                                          ),
                                          child: const Text(
                                            'Ambulance',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  // Create the second row with two buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height:
                                            80, // Set the height of the button
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Implement action for the first button
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BMICalculator()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            minimumSize:
                                                Size(screenWidth * 0.4, 80),
                                            backgroundColor:
                                                const Color.fromARGB(255, 4, 95,
                                                    169), // Button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12.0), // Border radius
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 20.0, // Padding
                                            ),
                                          ),
                                          child: const Text(
                                            'BMI Cal',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            80, // Set the height of the button
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Implement action for the first button
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title:
                                                          const Text("Logout?"),
                                                      content: const Text(
                                                          "Are you sure u wanna logout?"),
                                                      actions: [
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                "Cancle")),
                                                        ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        245,
                                                                        121,
                                                                        112)),
                                                            onPressed:
                                                                () async {
                                                              // Perform the logout action
                                                              await _signOut(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                "Confirm")),
                                                      ],
                                                    ));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            minimumSize:
                                                Size(screenWidth * 0.4, 80),
                                            backgroundColor:
                                                const Color.fromARGB(255, 85,
                                                    78, 51), // Button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12.0), // Border radius
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 20.0, // Padding
                                            ),
                                          ),
                                          child: const Text(
                                            'LogOut',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Implement action for the TextButton
                                      Navigator.pop(
                                          context); // Close the overlay
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                  // Set showBottomNavigationBar to true after returning from Menu
                  setState(() {
                    showBottomNavigationBar = true;
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Pop all routes until there are no more routes left
      Navigator.popUntil(context, (route) => route.isFirst);

      // Navigate back to the authentication screen or any other desired screen
      Navigator.pushReplacementNamed(
          context, 'auth'); // Replace with your authentication screen route
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
