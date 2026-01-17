import 'package:flutter/material.dart';

class StitchDesign extends StatefulWidget {
  const StitchDesign({super.key});

  @override
  State<StitchDesign> createState() => _StitchDesignState();
}

class _StitchDesignState extends State<StitchDesign> {
  // Artisan Theme Palette
  final Color primaryEarth = const Color(0xFFE27D5F);
  final Color goldAccent = const Color(0xFFD4A574);
  final Color clayBg = const Color(0xFFF5F2E9);
  final Color deepHeritage = const Color(0xFF4A7043);

  String email = '', password = '', confirmPassword = '';
  bool obscurePassword = true, obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Artisan Header
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [primaryEarth, goldAccent]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.brush, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text("Artisan Sign Up", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: deepHeritage)),
                ],
              ),
              const SizedBox(height: 48),
              // Email Field
              _ArtisanInputField(
                label: "Workshop Email",
                hint: "artisan@craft.com",
                icon: Icons.email_outlined,
                onChanged: (v) => email = v,
              ),
              const SizedBox(height: 20),
              // Password Field
              _ArtisanInputField(
                label: "Secure Password",
                hint: "Minimum 6 characters",
                icon: Icons.lock_outline,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: goldAccent),
                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                ),
                onChanged: (v) => password = v,
              ),
              const SizedBox(height: 20),
              // Confirm Password
              _ArtisanInputField(
                label: "Confirm Password",
                hint: "Re-enter password",
                icon: Icons.lock_reset_outlined,
                obscureText: obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: goldAccent),
                  onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                ),
                onChanged: (v) => confirmPassword = v,
              ),
              const SizedBox(height: 32),
              // Sign Up Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [deepHeritage, primaryEarth]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: primaryEarth.withOpacity(0.3), blurRadius: 20)],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _handleSignup(),
                    child: Center(
                      child: isLoading
                          ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text("Join Artisan Network", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Social Options
              Text("Or continue with", style: TextStyle(color: deepHeritage.withOpacity(0.7), fontSize: 16)),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _SocialButton(icon: Icons.g_mobiledata, label: "Google"),
                _SocialButton(icon: Icons.facebook, label: "Facebook"),
              ]),
              const SizedBox(height: 40),
              // Login Link
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: "Already crafting with us? ", style: TextStyle(color: deepHeritage.withOpacity(0.7))),
                        TextSpan(text: "Log In", style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignup() {
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email"), backgroundColor: Colors.orange)
      );
      return;
    }
    
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters"), backgroundColor: Colors.orange)
      );
      return;
    }
    
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.orange)
      );
      return;
    }
    
    setState(() => isLoading = true);
    
    // Simulate signup
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Welcome to KalaKriti!"), backgroundColor: primaryEarth)
      );
      Navigator.pop(context);
    });
  }
}

class _ArtisanInputField extends StatelessWidget {
  final String label, hint; 
  final IconData icon; 
  final bool obscureText; 
  final Widget? suffixIcon; 
  final ValueChanged<String> onChanged;
  
  const _ArtisanInputField({
    required this.label, 
    required this.hint, 
    required this.icon, 
    this.obscureText = false, 
    this.suffixIcon, 
    required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          TextField(
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: const Color(0xFFD4A574)),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
            ),
          ),
        ]
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon; 
  final String label;
  
  const _SocialButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.grey[700]), 
            const SizedBox(height: 8), 
            Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600))
          ]
        ),
      ),
    );
  }
}