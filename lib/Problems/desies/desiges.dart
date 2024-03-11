import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/Problems/SnivelCough.dart';
import 'package:demo/Problems/desies/Acidity/acidity.dart';
import 'package:demo/Problems/desies/fever/fever.dart';
import 'package:demo/Problems/desies/headache.dart';
import 'package:demo/ThemeSwitch.dart';
import 'package:demo/medical/users/doctor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Desiges extends StatefulWidget {
  @override
  State<Desiges> createState() => _DesigesState();
}

class _DesigesState extends State<Desiges> {
  bool isLoading = false;
  bool _isMounted = false;

  final CollectionReference<Map<String, dynamic>> usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<String?> getUserUid(String userEmail) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: '123456');
      return userCredential.user?.uid;
    } catch (e) {
      print('Error retrieving user UID: $e');
      return null;
    }
  }

  Future<String?> getUserPhoneNumber(String userUid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await usersCollection.doc(userUid).get();

      if (userSnapshot.exists) {
        return userSnapshot.data()?['number'];
      } else {
        return null; // User not found
      }
    } catch (e) {
      print('Error retrieving user information: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> fetchData() async {
    final userEmail = 'sabbir@gmail.com';

    if (!_isMounted) return;

    setState(() {
      isLoading = true;
    });

    final userUid = await getUserUid(userEmail);

    if (!_isMounted) return;

    print("userUid: $userUid");

    final phoneNumber = await getUserPhoneNumber(userUid!);

    if (!_isMounted) return;

    print("phoneNumber:+$phoneNumber");

    setState(() {
      isLoading = false;
    });

    if (phoneNumber != null) {
      try {
        launch("tel:$phoneNumber");
      } catch (e) {
        print('Error launching phone call: $e');
      }
    } else {
      print('User phone number not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Desiges Page'),
            backgroundColor: Colors.blue,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.themeMode == ThemeMode.dark
                  ? null // No gradient for dark theme
                  : const LinearGradient(
                      colors: [
                        Color(0xff85ffc0),
                        Color(0xff7eade7),
                        Color(0xff80ffd9)
                      ],
                      stops: [0.1, 0.5, 1],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                    ),
              color: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.grey[900] // Default color for dark theme
                  : null, // No default color for light theme
            ),
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  elevation: 5.0,
                  margin: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          "Emergency",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "If you need an ambulance, make a call.",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await fetchData();
                              },
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text("Call"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => userDoctorPage(),
                                  ),
                                );
                              },
                              child: const Text("View Doctor"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  'Types Of Desiges!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(
                    height: 20), // Increase the space between text and buttons

                // Button Row 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCustomButton(
                      'Fever',
                      'assets/flu_8799347.png',
                      () {
                        _navigateToPage(context, 'Fever Page');
                      },
                    ),
                    _buildCustomButton(
                      'Headache',
                      'assets/headache_5726955.png',
                      () {
                        _navigateToPage(context, 'Headache Page');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Add some spacing

                // Button Row 2
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCustomButton(
                      'Acidity',
                      'assets/health_13849357.png',
                      () {
                        _navigateToPage(context, 'Acidity Page');
                      },
                    ),
                    _buildCustomButton(
                      'Snivel or Cuff',
                      'assets/cold_6563831.png',
                      () {
                        _navigateToPage(context, 'Snivel or Cuff Page');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Add some spacing
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomButton(
      String buttonText, String iconAsset, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xfff7941e), Color(0xff004e8f)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              iconAsset,
              width: 88.0,
              height: 88.0,
            ),
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          minimumSize: const Size(150, 150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String pageName) {
    // You can replace MyFeverPage, MyHeadachePage, etc. with your actual page classes
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _getPageForName(pageName)),
    );
  }

  Widget _getPageForName(String pageName) {
    // Implement logic to return the appropriate page based on pageName
    // For example, you might have classes like MyFeverPage, MyHeadachePage, etc.
    switch (pageName) {
      case 'Fever Page':
        return const FeverPage();
      case 'Headache Page':
        return const HeadachePage();
      case 'Acidity Page':
        return const Acidity();
      case 'Snivel or Cuff Page':
        return const SnivelCough();
      default:
        return Container(); // Placeholder, you should handle this case accordingly
    }
  }
}
