import 'package:flutter/material.dart';

class LoginInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;

  const LoginInputField({
    super.key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.onChanged,
    this.validator,
  });

  @override
  State<LoginInputField> createState() => LoginInputFieldState();
}

class LoginInputFieldState extends State<LoginInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Color(0xFF161411),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5DDDB), width: 1),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFFFFFF),
              ),
              height: 56,
              width: double.infinity,
              child: TextFormField(
                obscureText: widget.isPassword ? _obscureText : false,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  suffixIcon: widget.isPassword
                      ? IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                      : null,
                ),
                onChanged: widget.onChanged,
                validator: widget.validator,
              ),
            ),
          ],
        ),
      ),
    );
  }
}