import 'package:flutter/material.dart';

class LoadingButtonPage extends StatefulWidget {
  @override
  _LoadingButtonPageState createState() => _LoadingButtonPageState();
}

class _LoadingButtonPageState extends State<LoadingButtonPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Carts'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Set the loading state to true
            setState(() {
              isLoading = true;
            });

            // Simulate a time-consuming task
            Future.delayed(Duration(seconds: 2), () {
              // Set the loading state back to false when the task is complete
              setState(() {
                isLoading = false;
              });
            });
          },
          child: isLoading
              ? CircularProgressIndicator(
                  // Customize the appearance of the loading indicator
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text('Click Me'),
        ),
      ),
    );
  }
}

class MyAppExtra extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnackBar Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SnackBar Demo'),
        ),
        body: const SnackBarPage(),
      ),
    );
  }
}

class SnackBarPage extends StatelessWidget {
  const SnackBarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Show a SnackBar when the button is pressed
          final snackBar = SnackBar(
            content: Text('Yay! A SnackBar!'),
          );

          // Find the ScaffoldMessenger in the widget tree
          // and use it to show a SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: Text('Show SnackBar'),
      ),
    );
  }
}
