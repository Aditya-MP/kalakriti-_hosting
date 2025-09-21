import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully!');
    // Force sign-out on cold start so app always begins at LoginScreen
    await FirebaseAuth.instance.signOut();
    // Test Firestore connection
    await testFirestoreConnection();
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  runApp(MyApp());
}

Future<void> testFirestoreConnection() async {
  try {
    // Try to write a test document
    await firestoreInstance
        .collection('test')
        .doc('connection_test')
        .set({
          'timestamp': DateTime.now(),
          'message': 'Firebase connection test successful'
        });
    print('Firestore write operation successful!');
    // Try to read the test document
    final doc = await firestoreInstance
        .collection('test')
        .doc('connection_test')
        .get();
    if (doc.exists) {
      print('Firestore read operation successful!');
      print('Test data: ${doc.data()}');
    }
  } catch (e) {
    print('Firestore test failed: $e');
  }
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

// Auth wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          
          if (user != null) {
            // User is signed in
            return LandingScreen();
          } else {
            // User is not signed in
            return LoginScreen(
              onLogin: (user) {
                // This will be handled automatically by the stream
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
                        // Pop back to Login with success result
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
        
        // Show a loading indicator while checking authentication state
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}