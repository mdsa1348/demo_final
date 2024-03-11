import 'package:flutter/material.dart';

class SelfCare extends StatelessWidget {
  const SelfCare({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self-Care After a Bone Fracture'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelfCareStep(1,
                "Avoid direct heat until the cast has set properly (e.g., hot water bottles)."),
            SelfCareStep(2, "Rest the limb as much as possible."),
            SelfCareStep(3,
                "Use proper techniques for walking and daily activities as instructed by nurses to avoid further injury."),
            SelfCareStep(
                4, "Avoid lifting or driving until the fracture has healed."),
            SelfCareStep(5,
                "If the skin under the cast is itchy, do not insert objects between the cast and your limb. Instead, use a hairdryer to blow cool air into the cast."),
            SelfCareStep(6,
                "Keep the cast dry; wet plaster can soften and irritate your skin. When showering, wrap the cast in a plastic bag and tape it securely to your skin to keep it watertight."),
            SelfCareStep(7,
                "Contact your doctor immediately if you experience swelling, blueness, loss of finger or toe movement, pins and needles, numbness, or increased pain."),
          ],
        ),
      ),
    );
  }
}

class SelfCareStep extends StatelessWidget {
  final int stepNumber;
  final String description;

  const SelfCareStep(this.stepNumber, this.description, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stepNumber.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }
}
