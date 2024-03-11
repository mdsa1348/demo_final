import 'package:demo/SuperAdminsThing/option1.dart';
import 'package:demo/SuperAdminsThing/option2.dart';
import 'package:flutter/material.dart';


class SuperAdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SuperAdmin Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the new page when Option 1 is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Option1Page(),
                  ),
                );
              },
              child: Text('Option 1'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyFlutterApp(),
                  ),
                );
              },
              child: Text('Option 2'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle button click
                // Add your logic for the third button here
              },
              child: Text('Option 3'),
            ),
          ],
        ),
      ),
    );
  }
}
