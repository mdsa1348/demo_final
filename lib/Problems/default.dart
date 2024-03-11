import 'package:flutter/material.dart';

class SnivelCough extends StatefulWidget {
  const SnivelCough({Key? key}) : super(key: key);

  @override
  _SnivelCoughState createState() => _SnivelCoughState();
}

class _SnivelCoughState extends State<SnivelCough> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snivel and Cough"),
        backgroundColor: Colors.blue, // Customize the color as needed
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
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
                            onPressed: () {
                              // Add your emergency call functionality
                            },
                            child: Text("Call"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Add navigation to view doctor screen
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
                "Options for Snivel and Cough.",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    text: "Symptoms",
                    width: MediaQuery.of(context).size.width / 2.25,
                    height: MediaQuery.of(context).size.width / 2.25,
                    imagePath: 'assets/snivel_cough_symptoms.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SnivelCoughSymptoms(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    text: "First-aid",
                    width: MediaQuery.of(context).size.width / 2.25,
                    height: MediaQuery.of(context).size.width / 2.25,
                    imagePath: 'assets/snivel_cough_first_aid.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SnivelCoughFirstAid(),
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
                    text: "Diagnose",
                    width: MediaQuery.of(context).size.width / 2.25,
                    height: MediaQuery.of(context).size.width / 2.25,
                    imagePath: 'assets/snivel_cough_diagnose.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SnivelCoughDiagnose(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    text: "Self-care",
                    width: MediaQuery.of(context).size.width / 2.25,
                    height: MediaQuery.of(context).size.width / 2.25,
                    imagePath: 'assets/snivel_cough_self_care.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SnivelCoughSelfCare(),
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
  }
}

class SnivelCoughSymptoms extends StatelessWidget {
  const SnivelCoughSymptoms({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Symptoms"),
        // Customize the appBar as needed
      ),
      body: Container(
        // Customize the body container as needed
        child: Center(
          child: Text("Symptoms Page"), // Add your symptoms content
        ),
      ),
    );
  }
}

class SnivelCoughFirstAid extends StatelessWidget {
  const SnivelCoughFirstAid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("First-aid"),
        // Customize the appBar as needed
      ),
      body: Container(
        // Customize the body container as needed
        child: Center(
          child: Text("First-aid Page"), // Add your first-aid content
        ),
      ),
    );
  }
}

class SnivelCoughDiagnose extends StatelessWidget {
  const SnivelCoughDiagnose({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnose"),
        // Customize the appBar as needed
      ),
      body: Container(
        // Customize the body container as needed
        child: Center(
          child: Text("Diagnose Page"), // Add your diagnose content
        ),
      ),
    );
  }
}

class SnivelCoughSelfCare extends StatelessWidget {
  const SnivelCoughSelfCare({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Self-care"),
        // Customize the appBar as needed
      ),
      body: Container(
        // Customize the body container as needed
        child: Center(
          child: Text("Self-care Page"), // Add your self-care content
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final String imagePath;
  final Function() onPressed;

  const CustomButton({
    Key? key,
    required this.text,
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
