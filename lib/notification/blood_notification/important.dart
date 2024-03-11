import 'package:flutter/material.dart';

class ImportantPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Important Page'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Important Lines',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                "Line 1: If this page doesn't show any details (even if you have some data), please go back and navigate to the notification page again.",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                "Line 2: Firstly Fill Your information.",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                "Line 3: Don't forget about this!",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
