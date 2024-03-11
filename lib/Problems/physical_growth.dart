import 'package:demo/ThemeSwitch.dart';
import 'package:demo/medical/users/doctor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhysicalGrowthPage extends StatefulWidget {
  const PhysicalGrowthPage({super.key});

  @override
  _PhysicalGrowthPageState createState() => _PhysicalGrowthPageState();
}

class _PhysicalGrowthPageState extends State<PhysicalGrowthPage> {
  List<bool> checkboxValues = List.generate(6, (index) => false);
  List<String> cardTexts = [
    "Normal Height",
    "Normal Weight",
    "Proper BMI",
    "Good Posture",
    "Healthy Diet",
    "Regular Exercise",
  ];

  // Two arrays for selection and values
  List<int> selectedIndexes = [];
  List<int> indexValues = [2, 2, 1, 1, 2, 1];

  void _showPopup() {
    int selectedCount = checkboxValues.where((element) => element).length;

    if (selectedCount >= 4) {
      _showAlertDialog(
        'Success',
        'You are on the right track for physical growth!',
        backgroundColor: Colors.green,
      );
    } else {
      _showAlertDialog(
        'Warning',
        'Ensure to focus on all aspects of physical growth.',
        backgroundColor: const Color.fromARGB(255, 50, 47, 19),
      );
    }
  }

  void _showAlertDialog(String title, String content,
      {Color backgroundColor = Colors.white}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          backgroundColor: backgroundColor,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        userDoctorPage(), // Replace DoctorPage with your actual page
                  ),
                );
              },
              child: const Text('Visit Doctor'),
            ),
          ],
        );
      },
    );
  }

  void _calculateAndShowResult() {
    // Calculate the sum of selected indexes' values
    int sumOfSelectedValues = selectedIndexes
        .map((index) => indexValues[index])
        .reduce((a, b) => a + b);

    // Calculate the total sum of indexValues array
    int totalSum = indexValues.reduce((a, b) => a + b);

    // Calculate the percentage
    double percentage = (sumOfSelectedValues / totalSum) * 100;

    // Show the result in an AlertDialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Physical Growth Results'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Percentage of selected values: ${percentage.toStringAsFixed(2)}%',
              ),
              const SizedBox(height: 10),
              if (percentage <= 30)
                _buildResultCard(
                  'Success',
                  'You are on the right track for physical growth!',
                  backgroundColor: Colors.green,
                )
              else if (percentage >= 30 && percentage <= 55)
                _buildResultCard(
                  'Unsure',
                  'You are on the Unsure Stage for physical growth!',
                  backgroundColor: Colors.green,
                )
              else
                _buildResultCard(
                  'Warning',
                  'Ensure to focus on all aspects of physical growth.',
                  backgroundColor: const Color.fromARGB(255, 102, 95, 33),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultCard(String title, String content,
      {Color backgroundColor = Colors.white}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(content),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Physical Growth Page'),
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[700] // Dark theme background color
                : Colors.blue,
          ),
          body: Container(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900]
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 204, 204, 204),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Physical growth is crucial for overall health and well-being. Ensure you focus on various aspects to support your physical development.",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        for (int i = 0; i < cardTexts.length; i++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: checkboxValues[i]
                                  ? Colors.blueAccent
                                  : const Color.fromARGB(255, 82, 82, 82),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: checkboxValues[i],
                                  onChanged: (value) {
                                    setState(() {
                                      checkboxValues[i] = value!;
                                      if (value!) {
                                        selectedIndexes.add(i);
                                      } else {
                                        selectedIndexes.remove(i);
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    cardTexts[i],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: checkboxValues[i]
                                          ? const Color.fromARGB(255, 0, 0,
                                              0) // Text color when checked
                                          : const Color.fromARGB(255, 255, 255,
                                              255), // Text color when unchecked
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _calculateAndShowResult();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Show Result'),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
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
