import 'package:demo/ThemeSwitch.dart';
import 'package:demo/medical/users/doctor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FractureOne extends StatefulWidget {
  const FractureOne({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyFractureState();
  }
}

class _MyFractureState extends State<FractureOne> {
  int currentCardIndex = 0;
  int yesCount = 0;
  int noCount = 0;

  @override
  void dispose() {
    // Reset variables when the widget is disposed
    currentCardIndex = 0;
    yesCount = 0;
    noCount = 0;
    selectedYesIndexes = [];
    super.dispose();
  }

  List<String> cardTexts = [
    "Card 1: Any visibly out-of-place or misshapen limb or joint?",
    "Card 2: Do you have Swelling, bruising, or bleeding?",
    "Card 3: feeling Intense pain, Numbness and tingling?",
    "Card 4: Broken skin with bone protruding?",
    "Card 5: Limited mobility or inability to move a limb or put weight on the leg.?",
  ];

  List<Color> cardColors = [
    const Color.fromARGB(255, 109, 110, 110),
    const Color.fromARGB(255, 162, 207, 163),
    const Color.fromARGB(255, 255, 201, 120),
    const Color.fromARGB(255, 244, 244, 244),
    const Color.fromARGB(255, 27, 110, 177),
  ];

  List<int> selectedYesIndexes = [];

  // Example array corresponding to selected indexes
  List<int> indexValue = [1, 2, 1, 2, 1];

  void _showPopUpCard(BuildContext context, int index) {
    Color cardColor = cardColors[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: cardColor,
          ),
          child: AlertDialog(
            title: const Text("Pop-Up Card"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  cardTexts[index],
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        yesCount++;
                        selectedYesIndexes.add(index);
                        Navigator.of(context).pop();
                        if (index < cardTexts.length - 1) {
                          _showPopUpCard(context, index + 1);
                        } else {
                          _showResult(context);
                        }
                      },
                      child: const Text("Yes"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        noCount++;
                        Navigator.of(context).pop();
                        if (index < cardTexts.length - 1) {
                          _showPopUpCard(context, index + 1);
                        } else {
                          _showResult(context);
                        }
                      },
                      child: const Text("No"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResult(BuildContext context) {
    String resultText;
    if (yesCount > noCount) {
      resultText = "You have higher possibilities of Fracture!";
    } else if (noCount > yesCount) {
      resultText = "Nothing to worry, it's maybe a scratch!";
    } else {
      resultText = "You should see a doctor";
    }

    // Print selected 'Yes' indexes during the survey
    print("Selected 'Yes' indexes during the survey: $selectedYesIndexes");

    // Print values from indexValue array corresponding to selected indexes
    List<int> selectedValues =
        selectedYesIndexes.map((index) => indexValue[index]).toList();
    print("Values corresponding to selected indexes: $selectedValues");

    // Calculate the sum of selected indexes' values
    int sumOfSelectedValues =
        selectedValues.reduce((value, element) => value + element);
    print("Sum of selected indexes' values: $sumOfSelectedValues");

    // Calculate the total sum of the indexValue array
    int totalSum = indexValue.reduce((value, element) => value + element);
    print("Total sum of indexValue array: $totalSum");

    // Calculate the percentage
    double percentage = (sumOfSelectedValues / totalSum) * 100;
    print("Percentage of selected values: $percentage%");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Survey Results"),
          content: Container(
            height: 200, // Set the height as per your requirement
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resultText,
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  "Chances of fracture : ${percentage.toStringAsFixed(2)}%",
                  style: TextStyle(
                      fontSize: 18,
                      backgroundColor:
                          const Color.fromARGB(255, 110, 147, 209)),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Reset variables or perform cleanup here
                currentCardIndex = 0;
                yesCount = 0;
                noCount = 0;
                selectedYesIndexes = [];

                Navigator.of(context).pop(); // Pop the dialog
                Navigator.of(context).pop(); // Pop the previous page
              },
              child: const Text("Close"),
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

  @override
  Widget build(BuildContext context) {
    const String fracturetext =
        "Fractures are different from other injuries to the skeleton such as dislocations, although in some cases, it can be hard to tell them apart. Sometimes, a person may have more than one type of injury. If in doubt, treat the injury as if it is a fracture. The symptoms of a fracture depend on the particular bone and the severity of the injury, but may include: ";
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Fracture Card Popup"),
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[700]
                : Colors.blue,
          ),
          body: Container(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900]
                : Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      color: Colors.amber[200],
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          fracturetext,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Click 'Next' to start the survey.",
                    style: TextStyle(
                      fontSize: 20,
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showPopUpCard(context, currentCardIndex);
                    },
                    child: const Text("Next"),
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
