import 'package:demo/medical/users/doctor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo/Problems/fracture/diagnosefracture.dart';
import 'package:demo/Problems/fracture/first_aid.dart';
import 'package:demo/Problems/fracture/selfcare.dart';
import 'package:demo/Problems/fracture/syntoms.dart';
import 'package:demo/ThemeSwitch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyFracture extends StatefulWidget {
  final bool showAppBar;
  final VoidCallback toggleAppBar;

  MyFracture({required this.showAppBar, required this.toggleAppBar});

  @override
  _MyFractureState createState() => _MyFractureState();
}

class _MyFractureState extends State<MyFracture> {
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
          appBar: widget.showAppBar
              ? AppBar(
                  title: const Text("Fracture"),
                  backgroundColor: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.grey[700]
                      : Colors.blue,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              : null,
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.themeMode == ThemeMode.dark
                  ? null
                  : LinearGradient(
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
                  ? Colors.grey[900]
                  : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                    elevation: 5.0,
                    margin: EdgeInsets.all(20.0),
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            "Emergency",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "If you need an ambulance, make a call.",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await fetchData();
                                },
                                child: isLoading
                                    ? CircularProgressIndicator()
                                    : Text("Call"),
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
                                child: Text("View Doctor"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    "Options for Fracture.",
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        "Symptoms",
                        width: MediaQuery.of(context).size.width / 2.25,
                        height: MediaQuery.of(context).size.width / 2.25,
                        imagePath: 'assets/toothache_9174502.png',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FractureOne(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      CustomButton(
                        "First-aid",
                        width: MediaQuery.of(context).size.width / 2.25,
                        height: MediaQuery.of(context).size.width / 2.25,
                        imagePath: 'assets/patch_435868.png',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FirstAidScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        "Diagnose",
                        width: MediaQuery.of(context).size.width / 2.25,
                        height: MediaQuery.of(context).size.width / 2.25,
                        imagePath: 'assets/examination_2749513.png',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Diagnose(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      CustomButton(
                        "Self-care",
                        width: MediaQuery.of(context).size.width / 2.25,
                        height: MediaQuery.of(context).size.width / 2.25,
                        imagePath: 'assets/plant_3921191.png',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelfCare(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final String imagePath; // New parameter for the image path
  final Function() onPressed;

  const CustomButton(
    this.text, {
    Key? key,
    required this.width,
    required this.height,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xfff7941e),
            Color(0xff004e8f),
          ],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(width, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          primary: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              imagePath,
              width: 98.0,
              height: 98.0,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
