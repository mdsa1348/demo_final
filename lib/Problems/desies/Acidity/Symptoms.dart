import 'package:demo/ThemeSwitch.dart';
import 'package:demo/medical/users/doctor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CiditySymptoms extends StatefulWidget {
  const CiditySymptoms({Key? key}) : super(key: key);

  @override
  _CiditySymptomsState createState() => _CiditySymptomsState();
}

class _CiditySymptomsState extends State<CiditySymptoms> {
  List<bool> checkboxValues = List.generate(8, (index) => false);

  List<String> cardTexts = [
    "Burning sensation or discomfort in the chest (heartburn)",
    "Nausea and vomiting",
    "Belching or burping",
    "Sour taste in the mouth",
    "Feeling bloated",
    "Difficulty swallowing",
    "Hoarseness or sore throat",
    "Dry cough",
  ];

  List<int> selectedIndexes = [];
  List<int> indexValues = [2, 2, 1, 1, 2, 1, 1, 2];

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
          title: const Text('Headache Results'),
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
                  'You are on the right track for managing headaches!',
                  backgroundColor: Colors.green,
                )
              else if (percentage >= 30 && percentage <= 55)
                _buildResultCard(
                  'Unsure',
                  'You are on the Unsure Stage for managing headaches!',
                  backgroundColor: Colors.green,
                )
              else
                _buildResultCard(
                  'Warning',
                  'Ensure to focus on all aspects of managing headaches.',
                  backgroundColor: const Color.fromARGB(255, 71, 68, 42),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acidity Page'),
      ),
      body: Padding(
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
                      color: const Color.fromARGB(255, 166, 166, 166),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Acidity is a common digestive condition that occurs when the stomach acid flows back into the esophagus, causing a burning sensation or discomfort in the chest known as heartburn. This condition is often referred to as acid reflux or gastroesophageal reflux disease (GERD). Acidity can manifest with various symptoms, and individuals experiencing",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  for (int i = 0; i < cardTexts.length; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: i == 0
                            ? Colors.green
                            : (checkboxValues[i]
                                ? Colors.blueAccent
                                : const Color.fromARGB(255, 70, 70, 70)),
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
                                    ? const Color.fromARGB(
                                        255, 0, 0, 0) // Text color when checked
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
            // Add your button here
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
    );
  }
}
