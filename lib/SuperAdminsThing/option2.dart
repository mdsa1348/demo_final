
// import 'package:demo/SuperAdminsThing/my_script.py';
import 'package:flutter/material.dart';
import 'package:dartpy/dartpy.dart';
import 'dart:ffi' as ffi;

class MyFlutterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter & Python Integration'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Call the Python function when the button is clicked
            callPythonFunction();
          },
          child: Text('Call Python Function'),
        ),
      ),
    );
  }

  void callPythonFunction() {
    // Initialize the Python runtime
    dartpyc.Py_Initialize();

    try {
      // Import the Python module
      final pythonModule =
          ffi.DynamicLibrary.open('lib/SuperAdminsThing/multiply.py');

      // Define the Python function
      final multiplyFunction = pythonModule.lookupFunction<
          ffi.Int32 Function(ffi.Int32, ffi.Int32),
          int Function(int, int)>('multiply');

      // Call the Python function
      final result = multiplyFunction(6, 4);
      print(result); // Should print 24
    } finally {
      // Cleanup the Python runtime
      dartpyc.Py_FinalizeEx();
    }
  }
}
