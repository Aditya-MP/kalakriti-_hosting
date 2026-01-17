import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/header_text.dart';
import '../components/login_input_field.dart';
import '../components/social_login_buttons.dart';
import '../components/primary_button.dart';

class LoginScreen extends StatefulWidget {
  final Function(User? user)? onLogin;
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

    // Test bypass for development
    if (_email == 'test@test.com' && _password == 'test123') {
      setState(() {
        _isLoading = false;
      });
      widget.onLogin?.call(null); // Pass null user for test
      return;
    }

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      widget.onLogin?.call(userCredential.user);
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Wrong password provided.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'Invalid email address.';
        } else {
          _errorMessage = 'Authentication failed: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Artisan theme: Earthy terracotta, gold accents, off-white, deep green
    final Color primaryEarth = const Color(0xFFE27D5F); // Terracotta
    final Color goldAccent = const Color(0xFFD4A574); // Artisan gold
    final Color clayBg = const Color(0xFFF5F2E9); // Off-white clay
    final Color deepHeritage = const Color(0xFF4A7043); // Heritage green
    final Color warmShadow = const Color(0xFFFFB997); // Warm glow

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              clayBg,
              clayBg.withOpacity(0.8),
              const Color(0xFFFDE8D7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Artisan header with handcrafted feel
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: primaryEarth.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                      border: Border.all(
                        color: goldAccent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          size: 80,
                          color: primaryEarth,
                        ),
                        const SizedBox(height: 16),
                        const HeaderText(
                          title: 'Welcome to KalaKrithi',
                          subtitle: 'Discover authentic artisan crafts',
                        ),
                      ],
                    ),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: primaryEarth, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Email field with artisan border
                  _ArtisanInputField(
                    key: const ValueKey('email-field'),
                    label: 'Email',
                    hintText: 'Enter your email',
                    icon: Icons.email_outlined,
                    color: primaryEarth,
                    isPassword: false,
                    onChanged: (val) => _email = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter your email';
                      if (!val.contains('@')) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Password field
                  _ArtisanInputField(
                    key: const ValueKey('password-field'),
                    label: 'Password',
                    hintText: 'Enter your password',
                    icon: Icons.lock_outline,
                    color: deepHeritage,
                    isPassword: true,
                    onChanged: (val) => _password = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter your password';
                      if (val.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Handcrafted button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryEarth, goldAccent],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: warmShadow,
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _isLoading ? null : _submit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoading) ...[
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Text(
                                _isLoading ? 'Signing In...' : 'Enter Artisan World',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Social divider
                  Row(
                    children: [
                      Expanded(child: _Divider(color: deepHeritage)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or',
                          style: TextStyle(
                            color: deepHeritage.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: _Divider(color: deepHeritage)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SocialLoginButtons(),
                  const SizedBox(height: 40),
                  // Signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New Artisan? ',
                        style: TextStyle(color: deepHeritage.withOpacity(0.8)),
                      ),
                      GestureDetector(
                        onTap: widget.onNavigateToSignup,
                        child: Text(
                          'Create Workshop',
                          style: TextStyle(
                            color: goldAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom artisan-styled input field
class _ArtisanInputField extends StatelessWidget {
  final Key? key;
  final String label;
  final String hintText;
  final IconData icon;
  final Color color;
  final bool isPassword;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const _ArtisanInputField({
    this.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.color,
    required this.isPassword,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: key,
            obscureText: isPassword,
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: color.withOpacity(0.5)),
              prefixIcon: Icon(icon, color: color.withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom divider
class _Divider extends StatelessWidget {
  final Color color;

  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: color.withOpacity(0.3),
    );
  }
}