import 'dart:async';

import 'package:demo/AuthenticationScreen.dart';
import 'package:demo/DemoHome.dart';
import 'package:demo/ThemeSwitch.dart';
import 'package:demo/auth_service.dart';
import 'package:demo/firebase_options.dart';
import 'package:demo/home_screen.dart';
import 'package:demo/notification/main_notification/notification_handler.dart';
import 'package:demo/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if the user is already authenticated
  User? user = FirebaseAuth.instance.currentUser;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProviderNotifier>(
          create: (_) => ThemeProviderNotifier(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        // Add other providers if needed
      ],
      child: ThemeProvider(
        themes: [
          AppTheme.light(),
          AppTheme.dark(),
          // Add other themes if needed
        ],
        child: MyApp(initialUser: user),
      ),
    ),
  );

  try {
    print('Tis is also printin');

    await FirebaseMessagingService()
        .initialize(); // Initialize messaging service

    print('Tis is also printin');

    // Initialize local notifications
    await initializeNotifications();

    await _requestNotificationPermission();
  } catch (e) {
    print('Firebase Analytics Initialization Error: $e');
  }
}

Future<void> _requestNotificationPermission() async {
  var status = await Permission.notification.request();

  if (status == PermissionStatus.granted) {
    // Permission granted, you can now handle notifications
    print('Notification permission granted');
    // Add your code to handle notifications here
  } else {
    // Permission denied
    print('Notification permission denied');
    // You may want to inform the user about the importance of the notification permission
  }
}

class MyApp extends StatelessWidget {
  final User? initialUser;

  const MyApp({Key? key, this.initialUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... existing configuration
      debugShowCheckedModeBanner: false,
      routes: {
        'auth': (context) => AuthenticationScreen(),
        'home': (context) => HomeScreen(),
        'admin_home': (context) => const HomePage(),
      },
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: SplashScreenAndNavigate(),
    );
  }
}

class SplashScreenAndNavigate extends StatefulWidget {
  @override
  _SplashScreenAndNavigateState createState() =>
      _SplashScreenAndNavigateState();
}

class _SplashScreenAndNavigateState extends State<SplashScreenAndNavigate> {
  @override
  void initState() {
    super.initState();
    // Add a delay before deciding where to navigate
    Timer(
      Duration(seconds: 5),
      () {
        // Check if there is a user already authenticated
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Navigator.pushReplacementNamed(context, 'home');
        } else {
          Navigator.pushReplacementNamed(context, 'auth');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Use your custom splash screen
  }
}
