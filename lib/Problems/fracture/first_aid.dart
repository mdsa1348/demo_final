import 'package:flutter/material.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fracture First Aid'),
      ),
      backgroundColor: const Color.fromARGB(255, 187, 187, 187),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FirstAidStep(
                number: 1,
                text:
                    "Keep the person still - do not move them unless there is an immediate danger, especially if you suspect fracture of the skull, spine, ribs, pelvis, or upper leg",
              ),
              FirstAidStep(
                number: 2,
                text:
                    "Attend to any bleeding wounds first. Stop the bleeding by pressing firmly on the site with a clean dressing. If a bone is protruding, apply pressure around the edges of the wound",
              ),
              FirstAidStep(
                number: 3,
                text:
                    "If bleeding is controlled, keep the wound covered with a clean dressing",
              ),
              FirstAidStep(
                  number: 4, text: "Never try to straighten broken bones"),
              FirstAidStep(
                number: 5,
                text:
                    "For a limb fracture, provide support and comfort such as a pillow under the lower leg or forearm. However, do not cause further pain or unnecessary movement of the broken bone",
              ),
              FirstAidStep(
                number: 6,
                text:
                    "Apply a splint to support the limb. Splints do not have to be professionally manufactured. Items like wooden boards and folded magazines can work for some fractures. You should immobilize the limb above and below the fracture",
              ),
              FirstAidStep(
                  number: 7,
                  text: "Use a sling to support an arm or collarbone fracture"),
              FirstAidStep(
                number: 8,
                text:
                    "Raise the fractured area if possible and apply a cold pack to reduce swelling and pain",
              ),
              FirstAidStep(
                number: 9,
                text:
                    "Stop the person from eating or drinking anything until they are seen by a doctor, in case they will need surgery",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstAidStep extends StatelessWidget {
  final int number;
  final String text;

  const FirstAidStep({super.key, required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Step $number:',
            style: const TextStyle(
              color: Colors.black, // Set text color to black
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black, // Set text color to black
            ),
          ),
        ],
      ),
    );
  }
}
