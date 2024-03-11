import 'package:demo/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email TextFormField
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email (ex@gmail.com)',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password TextFormField
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      _togglePasswordVisibility();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password should be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Sign Up and Sign In Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final snackBar = SnackBar(
                            content: Text('Signing Up...'),
                            duration: Duration(seconds: 2),
                            backgroundColor:
                                Colors.green, // Set your desired color
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          User? user =
                              await authService.signUpWithEmailAndPassword(
                            _emailController.text,
                            _passwordController.text,
                          );

                          if (user != null) {
                            //print('Signed up: ${user.email}');
                            _navigateToHome(context); // Navigate to home page
                            //_showMessage('You already have an account.');
                          } else {
                            _showMessage('You already have an account.');
                            //_navigateToHome(context);
                          }
                        } catch (e) {
                          print('1.Error signing up..: $e');

                          // Show the raw exception in a SnackBar
                          _showMessage('$e');

                          // Print the formatted error message
                          String errorMessage = _getErrorMessage(e);
                          print('2.Formatted Error Message: $errorMessage');

                          // Show the formatted error message in a SnackBar
                          _showMessage(errorMessage);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final snackBar = SnackBar(
                            content: Text('Signing In...'),
                            duration: Duration(seconds: 2),
                            backgroundColor:
                                Colors.green, // Set your desired color
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          User? user =
                              await authService.signInWithEmailAndPassword(
                            _emailController.text,
                            _passwordController.text,
                          );

                          if (user != null) {
                            print('Signed in: ${user.email}');
                            _navigateToHome(context); // Navigate to home page
                          } else {
                            print('Sign in failed');
                            _showMessage(
                                'Sign in failed, Wrong email or password');
                          }
                        } catch (e) {
                          print('Error signing in: $e');
                          String errorMessage = _getErrorMessage(e);
                          print('Formatted Error Message: $errorMessage');
                          _showMessage(errorMessage);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Forgot Password Text
              GestureDetector(
                onTap: () {
                  _forgotPassword();
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              // Display Error Message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(dynamic error) {
    print('2.Caught error type: ${error.runtimeType}');
    print('2.Error details: $error');

    String errorMessage = _getErrorMessage(error);

    print('4.Formatted Error Message: $errorMessage');

    // Check if the widget is still mounted before showing the SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              errorMessage.isNotEmpty ? errorMessage : 'An error occurred.'),
        ),
      );
    }
  }

  void _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      _showMessage('Please enter your email to reset the password.');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      _showMessage('Password reset email sent to ${_emailController.text}.');
    } catch (e) {
      _showMessage('Error sending password reset email: ${e.toString()}');
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        case 'email-already-in-use':
          return 'The email address is already in use by another account. If you forgot your password, you can reset it.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
        default:
          return 'An unknown authentication error occurred: ${error.code}';
      }
    } else if (error is String) {
      return 'Error: $error';
    }

    return 'An unknown error occurred: $error';
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, 'home');
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }
}
