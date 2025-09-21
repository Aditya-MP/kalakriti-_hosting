import 'package:flutter/material.dart';

class StitchDesign extends StatefulWidget {
	const StitchDesign({super.key});

	@override
	State<StitchDesign> createState() => _StitchDesignState();
}

class _StitchDesignState extends State<StitchDesign> {
	String email = '', password = '', confirmPassword = '';

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			resizeToAvoidBottomInset: true,
			body: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.symmetric(vertical: 48),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Container(
								padding: const EdgeInsets.all(16),
								child: Row(
									children: [
										Container(
											width: 24,
											height: 24,
											margin: const EdgeInsets.only(right: 24),
											child: Image.network("https://i.imgur.com/1tMFzp8.png"),
										),
										const Text(
											"Sign Up",
											style: TextStyle(
												color: Color(0xFF161411),
												fontSize: 18,
												fontWeight: FontWeight.bold,
											),
										),
									],
								),
							),
							// Email field
							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
								child: Container(
									padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(12),
										color: const Color(0xFFF4F2EF),
									),
									child: TextField(
										decoration: const InputDecoration(
											hintText: "Email",
											border: InputBorder.none,
											isDense: true,
										),
										style: const TextStyle(color: Color(0xFF897060), fontSize: 16),
										onChanged: (val) => email = val,
									),
								),
							),
							// Password field
							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
								child: Container(
									padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(12),
										color: const Color(0xFFF4F2EF),
									),
									child: TextField(
										obscureText: true,
										decoration: const InputDecoration(
											hintText: "Password",
											border: InputBorder.none,
											isDense: true,
										),
										style: const TextStyle(color: Color(0xFF897060), fontSize: 16),
										onChanged: (val) => password = val,
									),
								),
							),
							// Confirm Password field
							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
								child: Container(
									padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(12),
										color: const Color(0xFFF4F2EF),
									),
									child: TextField(
										obscureText: true,
										decoration: const InputDecoration(
											hintText: "Confirm Password",
											border: InputBorder.none,
											isDense: true,
										),
										style: const TextStyle(color: Color(0xFF897060), fontSize: 16),
										onChanged: (val) => confirmPassword = val,
									),
								),
							),
							// Social login buttons and Sign up button can be added here using your existing components or similar UI
							// For example:
							const SizedBox(height: 16),
							Center(child: Text("Continue with Google / Facebook - You'll add buttons here")),
							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
								child: Container(
									width: double.infinity,
									decoration: BoxDecoration(
										color: const Color(0xFFED772B),
										borderRadius: BorderRadius.circular(12),
									),
									child: TextButton(
										onPressed: () {
											// Implement your continue/signup logic here
										},
										child: const Text(
											"Sign Up",
											style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
										),
									),
								),
							),
							const SizedBox(height: 20),
							Center(
								child: TextButton(
									onPressed: () {
										Navigator.pop(context); // Back to login or previous
									},
									child: const Text("Already have an account? Log In"),
								),
							),
						],
					),
				),
			),
		);
	}
}
