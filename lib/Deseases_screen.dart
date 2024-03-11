import 'dart:ui';

import 'package:demo/DemoHome.dart';
import 'package:demo/Extra.dart';
import 'package:demo/Problems/desies/desiges.dart';
import 'package:demo/Problems/fracture/fracture.dart';
import 'package:demo/Problems/physical_growth.dart';
import 'package:demo/ThemeSwitch.dart';
import 'package:demo/blood/blood.dart';
import 'package:demo/bmi/bmi.dart';
import 'package:demo/chatting/chat.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:demo/medical/users/User_payment_page.dart';
import 'package:demo/medical/users/doctor.dart';
import 'package:demo/medical/users/image_user.dart';
import 'package:demo/notification/blood_notification/notification_Screen.dart';
import 'package:demo/notification/main_notification/SendNotiHandeler.dart';
import 'package:demo/notification/main_notification/notification_handler.dart';
import 'package:demo/notification/main_notification/usersnotice.dart';
import 'package:demo/profile/new.dart';
import 'package:demo/todo/todo_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';

class SecondScreen extends StatelessWidget {
  final ThemeProviderNotifier themeProvider;
  final VoidCallback toggleAppBar;
  SecondScreen({required this.themeProvider, required this.toggleAppBar});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  get selectedIndex => 1;
  bool showAppBar = true;

  AutoCompleteTextField<String> buildSearchBar(
      BuildContext context, List<String> suggestions) {
    ThemeProviderNotifier themeProvider =
        Provider.of<ThemeProviderNotifier>(context);

    return AutoCompleteTextField<String>(
      key: GlobalKey(),
      decoration: const InputDecoration(
        hintText: 'Search...',
        fillColor: Color.fromARGB(255, 255, 67, 67),
        prefixIcon: Icon(Icons.search),
        border: InputBorder.none,
      ),
      suggestions: suggestions ?? [],
      itemBuilder: (context, suggestion) => Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius:
                BorderRadius.circular(15.0), // Set the desired border radius
          ),
          child: ListTile(
            title: Text(
              suggestion,
              style: TextStyle(
                color: themeProvider.themeMode == ThemeMode.dark
                    ? const Color.fromARGB(
                        255, 0, 0, 0) // Dark theme text color
                    : Colors.black, // Light theme text color
              ),
            ),
          ),
        ),
      ),
      itemFilter: (suggestion, query) =>
          suggestion.toLowerCase().contains(query.toLowerCase()),
      itemSorter: (a, b) => a.compareTo(b),
      itemSubmitted: (item) {
        // Use the null-aware operator ?? to provide a default value
        item ??= "";

        // Ensure that the item is not empty before navigating
        if (item.isNotEmpty) {
          navigateToPage(context, item);
        } else {
          // Handle the case when the item is null or empty
          print('Invalid item submitted');
        }
      },
      textSubmitted: (item) {
        // Use the null-aware operator ?? to provide a default value
        item ??= "";

        // Ensure that the item is not empty before navigating
        if (item.isNotEmpty) {
          // Find an exact match for the entered text in suggestions
          String exactMatch = suggestions.firstWhere(
            (suggestion) => suggestion.toLowerCase() == item.toLowerCase(),
            orElse: () => "",
          );

          if (exactMatch.isNotEmpty) {
            // Navigate to the page for the exact match
            navigateToPage(context, exactMatch);
          } else {
            // Handle the case when there is no exact match
            print('No exact match found for item: $item');
          }
        } else {
          // Handle the case when the item is null or empty
          print('Invalid item submitted');
        }
      },
      clearOnSubmit: true,
      textInputAction: TextInputAction.search,
      textChanged: (text) {
        // Handle text changes (optional)
        print('Current text: $text');
        // You can filter your data or perform any other action here
      },
      onFocusChanged: (hasFocus) {
        // Handle focus changes (optional)
        print('Search bar focused: $hasFocus');
      },
      controller: TextEditingController(),
    );
  }

  void navigateToPage(BuildContext context, String selectedItem) {
    // Use a switch or if-else statements to determine the page based on the selected item
    switch (selectedItem.toLowerCase()) {
      case 'fracture':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyFracture(
              showAppBar: showAppBar,
              toggleAppBar: toggleAppBar,
            ),
          ),
        );
        break;
      case 'n':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyFracture(
              showAppBar: showAppBar,
              toggleAppBar: toggleAppBar,
            ),
          ),
        );
        break;
      case 'disease':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Desiges()),
        );
        break;
      case 'physical growth':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PhysicalGrowthPage()),
        );
        break;
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyProfilePage()),
        );
        break;
      case 'blood notification':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        );
        break;
      case 'notification':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => userNoticeBoard()),
        );
        break;
      case 'user todo':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TodoPage()),
        );
        break;
      case 'doctors':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => userDoctorPage()),
        );
        break;
      case 'blood service':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BloodPage()),
        );
        break;
      case 'bmi app':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BMICalculator()),
        );
        break;
      case 'button 2':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoadingButtonPage()),
        );
        break;
      // Add more cases for other items as needed

      default:
        // Handle default case or show an error message
        print('Page not found for item: $selectedItem');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Define the suggestions list within the build method
    List<String> suggestions = [
      'Fracture',
      'N',
      'Doctors',
      'Disease',
      'Physical Growth',
      'Blood Service',
      'BMI APP',
      'Button 2',
      'Ambulance',
      'Medicals',
      'Profile',
      'User Todo',
      'Notification',
      'Blood Notification',
    ];

    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, _child) {
        return Theme(
          data: ThemeData(
            brightness: themeProvider.themeMode == ThemeMode.dark
                ? Brightness.dark
                : Brightness.light,
          ),
          child: Scaffold(
            //appBar: showAppBar ? AppBar(title: Text('New Screen')) : null,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.grey[900] // Dark theme background color
                        : Color.fromARGB(
                            255, 220, 219, 219), // Light theme background color

                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // const Text(
                          //   'Select the Type of Diseases',
                          //   style: TextStyle(fontSize: 20),
                          // ),
                          const SizedBox(
                            height: 80,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xfff7941e),
                                      Color(0xff004e8f)
                                    ],
                                    stops: [0, 1],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyFracture(
                                          showAppBar: showAppBar,
                                          toggleAppBar: toggleAppBar,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(screenWidth * 0.4, 150),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: Colors
                                        .transparent, // Set a transparent background color
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset(
                                        'assets/bone_11288240.png',
                                        width:
                                            98.0, // Adjust the width of the image
                                        height:
                                            98.0, // Adjust the height of the image
                                      ),
                                      Text(
                                        'Fracture',
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xfff7941e),
                                      Color(0xff004e8f)
                                    ],
                                    stops: [0, 1],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Desiges(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(screenWidth * 0.5, 150),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: Colors
                                        .transparent, // Set a transparent background color
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset(
                                        'assets/human_11431001.png',
                                        width:
                                            98.0, // Adjust the width of the image
                                        height:
                                            98.0, // Adjust the height of the image
                                      ),
                                      Text(
                                        'Diseases',
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xfff7941e),
                                      Color(0xff004e8f)
                                    ],
                                    stops: [0, 1],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PhysicalGrowthPage(),
                                      ),
                                    );
                                  },
                                  icon: Image.asset(
                                    'assets/employee_5371502.png', // Adjust the path to your image
                                    width:
                                        88.0, // Adjust the width of the image
                                    height:
                                        88.0, // Adjust the height of the image
                                  ),
                                  label: const Text(
                                    ' Physical Growth',
                                    style: TextStyle(
                                      fontSize: 22.0, // Adjust the font size
                                      fontWeight: FontWeight
                                          .bold, // Adjust the font weight
                                      fontStyle: FontStyle
                                          .italic, // Adjust the font style
                                      color:
                                          Colors.white, // Adjust the text color
                                      //background:;
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .transparent, // Set a transparent background color
                                    minimumSize: Size(screenWidth * 0.9, 100),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20.0), // Adjust the border radius
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xfff7941e),
                                      Color(0xff004e8f)
                                    ],
                                    stops: [0, 1],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => BloodPage()),
                                    );
                                  },
                                  icon: Image.asset(
                                    'assets/blood-donation_7645101.png', // Adjust the path to your image
                                    width:
                                        98.0, // Adjust the width of the image
                                    height:
                                        98.0, // Adjust the height of the image
                                  ),
                                  label: const Text(
                                    'Blood Service',
                                    style: TextStyle(
                                      fontSize: 24.0, // Adjust the font size
                                      fontWeight: FontWeight
                                          .bold, // Adjust the font weight
                                      fontStyle: FontStyle
                                          .italic, // Adjust the font style
                                      color:
                                          Colors.white, // Adjust the text color
                                      //background:;
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .transparent, // Set a transparent background color
                                    minimumSize: Size(screenWidth * 0.9, 130),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20.0), // Adjust the border radius
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xfff7941e),
                                      Color(0xff004e8f)
                                    ],
                                    stops: [0, 1],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BMICalculator(),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset(
                                        'assets/speedometer_4381176.png',
                                        width:
                                            98.0, // Adjust the width of the image
                                        height:
                                            98.0, // Adjust the height of the image
                                      ),
                                      Text(
                                        'BMI App',
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(screenWidth * 0.5, 150),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: Colors
                                        .transparent, // Set a transparent background color
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xfff7941e),
                                      Color(0xff004e8f)
                                    ],
                                    stops: [0, 1],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Usage example
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoadingButtonPage(),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset(
                                        'assets/extra_5129658.png',
                                        width:
                                            88.0, // Adjust the width of the image
                                        height:
                                            88.0, // Adjust the height of the image
                                      ),
                                      Text(
                                        'Extra',
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .transparent, // Set a transparent background color
                                    minimumSize: Size(screenWidth * 0.4, 150),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20.0), // Adjust the border radius
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 15.0,
                              bottom: 5.0,
                              left: 15.0,
                              right: 15.0), // Adjust the margin as needed
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.white.withOpacity(
                                0.7), // Adjust the opacity as needed
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: buildSearchBar(context, suggestions),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
