import 'package:demo/SuperAdminsThing/superAdmin.dart';
import 'package:demo/ThemeSwitch.dart';
import 'package:demo/blood/blood.dart';
import 'package:demo/chatting/chat.dart';
import 'package:demo/chatting/userid.dart';
import 'package:demo/medical/admin/allUsers.dart';
import 'package:demo/medical/admin/ambulance.dart';
import 'package:demo/medical/admin/doctor.dart';
import 'package:demo/medical/admin/medicals.dart';
import 'package:demo/notification/main_notification/adminNotice.dart';

import 'package:demo/profile/new.dart';
import 'package:demo/todo/todo_Page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double buttonHeight = MediaQuery.of(context).size.height * 0.1;
    double buttonWidth = MediaQuery.of(context).size.width * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TodoPage()),
                  );
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('Mytodo')),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BloodPage()),
                  );
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('Blood')),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyProfilePage()),
                  );
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('Profile')),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DemoChats(
                          themeProvider:
                              Provider.of<ThemeProviderNotifier>(context)),
                    ),
                  );
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('Chat')),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminHospitalPage()),
                  );
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('Medical')),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminDoctorPage(),
                    ),
                  );
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('Doctor')),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SuperAdminPage()),
                  );
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('SuperAdmin')),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminAllUsersPage(),
                    ),
                  );
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('All Users')),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminAmbulancePage()),
                  );
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('Ambulance')),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DemoChats(
                        themeProvider:
                            Provider.of<ThemeProviderNotifier>(context),
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('Contract us')),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoticeBoard(),
                    ),
                  );
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('Admin notice')),
                ),
              ),
              SizedBox(width: 8), // Add some spacing between buttons
              ElevatedButton(
                onPressed: () async {
                  await _signOut(context);
                },
                child: SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: Center(child: Text('Logout')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, 'auth');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
