import 'package:flutter/material.dart';

class Diagnose extends StatelessWidget {
  const Diagnose({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bone Fracture Information'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Doctors can diagnose bone fractures with x-rays. They may also use CT scans (computed tomography) and MRI scans (magnetic resonance imaging).\n\n'
          'Broken bones heal by themselves – the aim of medical treatment is to make sure the pieces of bone are lined up correctly. The bone needs to recover fully in strength, movement, and sensitivity. Some complicated fractures may need surgery or surgical traction (or both).\n\n'
          'Depending on where the fracture is and how severe, treatment may include:\n\n'
          '1. Splints - to stop movement of the broken limb\n'
          '2. Braces - to support the bone\n'
          '3. Plaster cast - to provide support and immobilize the bone\n'
          '4. Traction - a less common option\n'
          '5. Surgically inserted metal rods or plates - to hold the bone pieces together\n'
          '6. Pain relief.',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
