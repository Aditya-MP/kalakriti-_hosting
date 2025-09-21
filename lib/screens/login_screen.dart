import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/header_text.dart';
import '../components/login_input_field.dart';
import '../components/social_login_buttons.dart';
import '../components/primary_button.dart';

class LoginScreen extends StatefulWidget {
  final Function(User? user) onLogin;
  final VoidCallback onNavigateToSignup;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onNavigateToSignup,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _email = '';
  String _password = '';
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      
      widget.onLogin(userCredential.user);
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Wrong password provided.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'Invalid email address.';
        } else {
          _errorMessage = 'Authentication failed. Please try again.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                HeaderText(
                  title: 'Welcome to KalaKrithi',
                  subtitle: 'Discover and support authentic artisans',
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      _errorMessage, 
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                LoginInputField(
                  key: const ValueKey('email-field'),
                  label: 'Email',
                  hintText: 'Enter your email',
                  isPassword: false,
                  onChanged: (val) => _email = val ?? '',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter your email';
                    if (!val.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                LoginInputField(
                  key: const ValueKey('password-field'),
                  label: 'Password',
                  hintText: 'Enter your password',
                  isPassword: true,
                  onChanged: (val) => _password = val ?? '',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter your password';
                    if (val.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator()
                    : PrimaryButton(
                        text: 'Log In',
                        onPressed: _submit,
                      ),
                const SizedBox(height: 16),
                const Text(
                  'Or continue with',
                  style: TextStyle(color: Color(0xFF897060)),
                ),
                const SizedBox(height: 12),
                const SocialLoginButtons(),
                TextButton(
                  onPressed: widget.onNavigateToSignup,
                  child: const Text('New User? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}