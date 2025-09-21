import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                text: 'Google',
                onTap: () => print('Google Login'),
                isLeftButton: true,
              ),
            ),
            Expanded(
              child: _buildSocialButton(
                text: 'Facebook',
                onTap: () => print('Facebook Login'),
                isLeftButton: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required VoidCallback onTap,
    bool isLeftButton = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF4F2EF),
        ),
        padding: const EdgeInsets.symmetric(vertical: 9),
        margin: isLeftButton ? const EdgeInsets.only(right: 12) : null,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF161411),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}