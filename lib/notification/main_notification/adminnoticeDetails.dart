import 'package:flutter/material.dart';

class NoticeDetail extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  NoticeDetail(
      {required this.title, required this.description, this.imageUrl = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notice Detail'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                description,
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              imageUrl.isNotEmpty ? Image.network(imageUrl) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
