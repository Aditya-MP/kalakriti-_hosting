import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onNavigateToLogin;
  final Function(User? user) onSignupSuccess;

  const SignupScreen({
    super.key,
    required this.onNavigateToLogin,
    required this.onSignupSuccess,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Artisan Theme Palette
  final Color primaryEarth = const Color(0xFFE27D5F);
  final Color goldAccent = const Color(0xFFD4A574);
  final Color clayBg = const Color(0xFFF5F2E9);
  final Color deepHeritage = const Color(0xFF4A7043);

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_password != _confirmPassword) {
      setState(() => _errorMessage = "Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      widget.onSignupSuccess(userCredential.user);
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'weak-password': _errorMessage = 'Password too weak (6+ characters)'; break;
          case 'email-already-in-use': _errorMessage = 'Email already registered'; break;
          case 'invalid-email': _errorMessage = 'Invalid email format'; break;
          default: _errorMessage = 'Registration failed: ${e.message}';
        }
      });
    } catch (e) {
      setState(() => _errorMessage = 'Network error. Try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBg,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // Artisan Welcome Header
                Container(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.only(bottom: 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryEarth, goldAccent]),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [BoxShadow(color: primaryEarth.withOpacity(0.3), blurRadius: 25)],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.eco, size: 72, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text("Join KalaKriti", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Support authentic artisans", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                    ],
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15), 
                      borderRadius: BorderRadius.circular(16), 
                      border: Border.all(color: Colors.orange.withOpacity(0.4))
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange), 
                        const SizedBox(width: 12), 
                        Expanded(child: Text(_errorMessage, style: TextStyle(color: Colors.orange[800])))
                      ]
                    ),
                  ),
                // Email Field
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(20), 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12)]
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Artisan Email", 
                      labelStyle: TextStyle(color: deepHeritage),
                      hintText: "yourcraft@email.com",
                      prefixIcon: Icon(Icons.email_outlined, color: goldAccent),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val?.isEmpty == true) return 'Enter email';
                      if (!val!.contains('@')) return 'Valid email required';
                      return null;
                    },
                    onSaved: (val) => _email = val!.trim(),
                  ),
                ),
                // Password Field
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(20), 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12)]
                  ),
                  child: TextFormField(
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Craft Password", 
                      labelStyle: TextStyle(color: deepHeritage),
                      hintText: "Strong password (6+ chars)",
                      prefixIcon: Icon(Icons.lock_outline, color: goldAccent),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), 
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword)
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (val) => (val?.length ?? 0) < 6 ? 'Password too short' : null,
                    onSaved: (val) => _password = val!,
                    onChanged: (val) => _password = val,
                  ),
                ),
                // Confirm Password
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(20), 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12)]
                  ),
                  child: TextFormField(
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: "Confirm Password", 
                      labelStyle: TextStyle(color: deepHeritage),
                      prefixIcon: Icon(Icons.lock_outlined, color: goldAccent),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility), 
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (val) => val != _password ? 'Passwords must match' : null,
                    onSaved: (val) => _confirmPassword = val!,
                  ),
                ),
                // Sign Up Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [deepHeritage, primaryEarth]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: deepHeritage.withOpacity(0.3), blurRadius: 20)],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _isLoading ? null : _submit,
                      child: Center(
                        child: _isLoading 
                          ? const SizedBox(
                              width: 24, 
                              height: 24, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            ) 
                          : const Text(
                              "Join Artisan Community", 
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                            )
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Social Options
                Text("Or join with", style: TextStyle(color: deepHeritage.withOpacity(0.7))),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                  children: [
                    _SocialButton(icon: Icons.g_mobiledata, label: "Google", onTap: () => debugPrint('Google signup')),
                    _SocialButton(icon: Icons.facebook, label: "Facebook", onTap: () => debugPrint('Facebook signup')),
                  ]
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: widget.onNavigateToLogin,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: "Already a member? ", style: TextStyle(color: deepHeritage.withOpacity(0.7))),
                        TextSpan(text: "Log In", style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon; 
  final String label; 
  final VoidCallback onTap;
  
  const _SocialButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.grey[700]), 
            const SizedBox(height: 8), 
            Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500))
          ]
        ),
      ),
    );
  }
}