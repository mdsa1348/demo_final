// import 'package:demo/medical/users/doctor.dart';
// import 'package:flutter/material.dart';

// class FeverPage extends StatefulWidget {
//   const FeverPage({super.key});

//   @override
//   _FeverPageState createState() => _FeverPageState();
// }

// class _FeverPageState extends State<FeverPage> {
//   String selectedOption = '';
//   List<String> cardTexts = [];
//   List<bool> checkboxStates = [];

//   // Map to store selected count for each option
//   Map<String, int> selectedCounts = {
//     '(0-24 months)baby': 0,
//     '(2-17 year) young': 0,
//     '(18 year and above)': 0,
//   };

//   void showContent(String option) {
//     setState(() {
//       selectedOption = option;
//       cardTexts = [];

//       // Update cardTexts based on the selected option
//       if (option == '(0-24 months)baby') {
//         cardTexts.addAll([
//           "Your child looks or acts very sick ?",
//           "Any serious symptoms occur such as trouble breathing ?",
//           "Fever goes above 104° F (40° C) ?",
//           "Any fever occurs if less than 12 weeks old ?",
//           "Fever without other symptoms lasts more than 24 hours ?",
//           "Fever lasts more than 3 days (72 hours) ?",
//         ]);
//       } else if (option == '(2-17 year) young') {
//         cardTexts.addAll([
//           "You have a fever of 40°C or higher ?",
//           "You have a fever that stays high ?",
//           "You have a fever and feel confused or often feel dizzy ?",
//           "You have trouble breathing. ?",
//           "You have a fever with a stiff neck or a severe headache ?",
//           "You have any problems with your medicine, or you get a fever after starting a new medicine. ?",
//           "You do not get better as expected. ?",
//         ]);
//       } else if (option == '(18 year and above)') {
//         cardTexts.addAll([
//           "You have a fever of 40°C or higher ?",
//           "You have a fever that stays high ?",
//           "You have a fever with a stiff neck or a severe headache ?",
//           "You have any problems with your medicine, or you get a fever after starting a new medicine. ?",
//           "You do not get better as expected. ?",
//         ]);
//       }

//       // Update checkboxStates to match the length of cardTexts
//       checkboxStates = List.generate(cardTexts.length, (index) => false);
//     });
//   }

//   void handleArrayButtonClick() {
//     int selectedCount = checkboxStates.where((state) => state).length;

//     if (selectedCount >= 2) {
//       // Show a popup card with specific content for each option and more than or equal to 2 selected checkboxes
//       _showPopupCard(getPopupCardContent(selectedOption, true));
//     } else {
//       // Show a different popup card with specific content for each option and less than 2 selections
//       _showPopupCard(getPopupCardContent(selectedOption, false));
//     }
//   }

//   void _showPopupCard(String content) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Popup Card'),
//           content: Text(content),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           userDoctorPage()), // Replace DoctorPage with your actual page
//                 );
//               },
//               child: const Text('Visit Doctor'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   String getPopupCardContent(String option, bool moreThanTwoSelected) {
//     if (moreThanTwoSelected) {
//       switch (option) {
//         case '(0-24 months)baby':
//           return 'Call Doctor or Seek Care Now,Contact Doctor Within 24 Hours,Call 911 Now';
//         case '(2-17 year) young':
//           return 'Call Doctor or Seek Care Now,Contact Doctor Within 24 Hours,Call 911 Now';
//         case '(18 year and above)':
//           return 'Call Doctor or Seek Care Now,Contact Doctor Within 24 Hours,Call 911 Now';
//         default:
//           return 'Default Popup Card Content for more than 2 selections';
//       }
//     } else {
//       switch (option) {
//         case '(0-24 months)baby':
//           return 'Its ok, nothing to worry , but if u are not feeling right , then u can contract a Doctor.';
//         case '(2-17 year) young':
//           return 'Its ok, nothing to worry , but if u are not feeling right , then u can contract a Doctor.';
//         case '(18 year and above)':
//           return 'Its ok, nothing to worry , but if u are not feeling right , then u can contract a Doctor.';
//         default:
//           return 'Default Popup Card Content for less than 2 selections';
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Fever Options'),
//       ),
//       body: Container(
//         margin: EdgeInsets.only(top: 50),
//         child: SingleChildScrollView(
//           child: Center(
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             buildOption('(0-24 months)baby',
//                                 const Color.fromARGB(255, 255, 138, 130)),
//                             buildOption('(2-17 year) young', Colors.green),
//                             buildOption('(18 year and above)', Colors.blue),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.all(20),
//                         padding: EdgeInsets.all(10),
//                         color: getColorForOption(selectedOption),
//                         child: Column(
//                           children: [
//                             Text(
//                               selectedOption.isNotEmpty
//                                   ? 'Selected Option: $selectedOption'
//                                   : 'Select an option',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             SizedBox(height: 10),
//                             // Display checkboxes based on cardTexts
//                             if (cardTexts.isNotEmpty)
//                               Column(
//                                 children:
//                                     cardTexts.asMap().entries.map((entry) {
//                                   final cardIndex = entry.key;
//                                   final cardText = entry.value;

//                                   return CheckboxListTile(
//                                     title: Text(cardText),
//                                     controlAffinity:
//                                         ListTileControlAffinity.leading,
//                                     value: checkboxStates[cardIndex],
//                                     activeColor: Colors
//                                         .orange, // Change color when selected
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         checkboxStates[cardIndex] =
//                                             value ?? false;
//                                         // Handle checkbox state changes if needed
//                                         selectedCounts[selectedOption] =
//                                             checkboxStates
//                                                 .where((state) => state)
//                                                 .length;
//                                       });
//                                     },
//                                   );
//                                 }).toList(),
//                               ),
//                             SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Selected Count: ${checkboxStates.where((state) => state).length}',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                                 IconButton(
//                                   icon: Icon(Icons.arrow_forward),
//                                   onPressed: handleArrayButtonClick,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Color getColorForOption(String option) {
//     switch (option) {
//       case '(0-24 months)baby':
//         return const Color.fromARGB(255, 254, 164, 158);
//       case '(2-17 year) young':
//         return Colors.green;
//       case '(18 year and above)':
//         return Colors.blue;
//       default:
//         return Colors.green; // Default color
//     }
//   }

//   Widget buildOption(String option, Color color) {
//     return GestureDetector(
//       onTap: () => showContent(option),
//       child: Container(
//         padding: EdgeInsets.all(10),
//         color: color,
//         child: Text(
//           option,
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }
// }
