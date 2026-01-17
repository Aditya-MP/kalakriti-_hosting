import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully!');
  } catch (e) {
    print('Failed to load .env file: $e');
  }
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully!');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // Sign out when the app is terminating
      FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalakriti',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      onLogin: (user) {
        // Navigate to landing screen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingScreen()),
        );
      },
      onNavigateToSignup: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupScreen(
              onNavigateToLogin: () {
                Navigator.pop(context);
              },
              onSignupSuccess: (user) {
                Navigator.pop(context, true);
              },
            ),
          ),
        );
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! Please login.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }
}