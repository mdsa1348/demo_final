import 'package:demo/medical/users/doctor.dart';
import 'package:flutter/material.dart';

class FeverPage extends StatefulWidget {
  const FeverPage({super.key});

  @override
  _FeverPageState createState() => _FeverPageState();
}

class _FeverPageState extends State<FeverPage> {
  String selectedOption = '';
  List<String> cardTexts = [];
  List<bool> checkboxStates = [];
  Map<String, List<int>> sectionValues = {
    '(0-7 years)': [1, 2, 1, 1, 2, 1],
    '(2-17 years)': [2, 1, 2, 1, 1, 2, 1],
    '(18 years and above)': [1, 1, 2, 2, 1],
  };

  List<int> selectedIndexes = [];
  List<int> indexValues = [];

  void showContent(String option) {
    setState(() {
      selectedOption = option;
      cardTexts = [];

      if (sectionValues.containsKey(option)) {
        indexValues = sectionValues[option]!;
      } else {
        // Default values if the selected option is not found
        indexValues = List.generate(8, (index) => 1);
      }

      if (option == '(0-7 years)') {
        cardTexts.addAll([
          "Your child looks or acts very sick?",
          "Any serious symptoms occur such as trouble breathing?",
          "Fever goes above 104° F (40° C)?",
          "Any fever occurs if less than 12 weeks old?",
          "Fever without other symptoms lasts more than 24 hours?",
          "Fever lasts more than 3 days (72 hours)?",
        ]);
      } else if (option == '(2-17 years)') {
        cardTexts.addAll([
          "You have a fever of 40°C or higher?",
          "You have a fever that stays high?",
          "You have a fever and feel confused or often feel dizzy?",
          "You have trouble breathing?",
          "You have a fever with a stiff neck or a severe headache?",
          "You have any problems with your medicine, or you get a fever after starting a new medicine?",
          "You do not get better as expected?",
        ]);
      } else if (option == '(18 years and above)') {
        cardTexts.addAll([
          "You have a fever of 40°C or higher?",
          "You have a fever that stays high?",
          "You have a fever with a stiff neck or a severe headache?",
          "You have any problems with your medicine, or you get a fever after starting a new medicine?",
          "You do not get better as expected?",
        ]);
      }

      checkboxStates = List.generate(cardTexts.length, (index) => false);
    });
  }

  void handleArrayButtonClick() {
    int selectedCount = checkboxStates.where((state) => state).length;

    if (selectedCount >= 2) {
      _showPopupCard(getPopupCardContent(selectedOption, true));
    } else {
      _showPopupCard(getPopupCardContent(selectedOption, false));
    }
  }

  void _showPopupCard(String content) {
    // Print selected indexes and their values
    print('Selected Indexes: $selectedIndexes');
    print(
        'Selected Values: ${selectedIndexes.map((index) => indexValues[index])}');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Popup Card'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => userDoctorPage(),
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

  String getPopupCardContent(String option, bool moreThanTwoSelected) {
    if (moreThanTwoSelected) {
      // Calculate the sum of selected indexes' values
      int sumOfSelectedValues = selectedIndexes
          .map((index) => indexValues[index])
          .reduce((a, b) => a + b);

      // Calculate the total sum of indexValues array
      int totalSum = indexValues.reduce((a, b) => a + b);

      // Calculate the percentage
      double percentage = (sumOfSelectedValues / totalSum) * 100;

      switch (option) {
        case '(0-7 years)':
        case '(2-17 years)':
        case '(18 years and above)':
          return 'Percentage of selected values: ${percentage.toStringAsFixed(2)}%';
        default:
          return 'Default Popup Card Content for more than 2 selections';
      }
    } else {
      switch (option) {
        case '(0-7 years)':
        case '(2-17 years)':
        case '(18 years and above)':
          return 'It\'s ok, nothing to worry, but if you are not feeling right, then you can contact a Doctor.';
        default:
          return 'Default Popup Card Content for less than 2 selections';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fever Options'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildOption('(0-7 years)',
                                const Color.fromARGB(255, 255, 138, 130)),
                            buildOption('(2-17 years)', Colors.green),
                            buildOption('(18 years and above)', Colors.blue),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.all(10),
                        color: getColorForOption(selectedOption),
                        child: Column(
                          children: [
                            Text(
                              selectedOption.isNotEmpty
                                  ? 'Selected Option: $selectedOption'
                                  : 'Select an option',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 10),
                            if (cardTexts.isNotEmpty)
                              Column(
                                children:
                                    cardTexts.asMap().entries.map((entry) {
                                  final cardIndex = entry.key;
                                  final cardText = entry.value;

                                  return CheckboxListTile(
                                    title: Text(cardText),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: checkboxStates[cardIndex],
                                    activeColor: Colors.orange,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checkboxStates[cardIndex] =
                                            value ?? false;
                                        // Handle checkbox state changes if needed
                                        selectedIndexes = checkboxStates
                                            .asMap()
                                            .entries
                                            .where((entry) => entry.value)
                                            .map((entry) => entry.key)
                                            .toList();
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Selected Count: ${checkboxStates.where((state) => state).length}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward),
                                  onPressed: handleArrayButtonClick,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getColorForOption(String option) {
    switch (option) {
      case '(0-7 years)':
        return Color.fromARGB(255, 72, 62, 61);
      case '(2-17 years)':
        return const Color.fromARGB(255, 58, 77, 59);
      case '(18 years and above)':
        return Colors.blue;
      default:
        return Colors.green; // Default color
    }
  }

  Widget buildOption(String option, Color color) {
    return GestureDetector(
      onTap: () => showContent(option),
      child: Container(
        padding: EdgeInsets.all(10),
        color: color,
        child: Text(
          option,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
