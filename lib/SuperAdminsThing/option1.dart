// lib/option1_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';

class Option1Page extends StatefulWidget {
  @override
  _Option1PageState createState() => _Option1PageState();
}

class _Option1PageState extends State<Option1Page> {
  List<String> connectedDevices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Option 1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _getConnectedDevices,
              child: Text('Get Connected Devices'),
            ),
            SizedBox(height: 20),
            Text(
              'Connected Devices:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            for (var device in connectedDevices) Text(device),
          ],
        ),
      ),
    );
  }

  Future<void> _getConnectedDevices() async {
    final process = await Process.start('python', ['python_scripts/get_connected_devices.py']);
    final result = await process.stdout.transform(utf8.decoder).join();
    setState(() {
      connectedDevices = result.trim().split('\n');
    });
  }
}
