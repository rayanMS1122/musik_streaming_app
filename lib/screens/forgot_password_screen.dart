import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  /// Function to handle password reset
  Future<void> resetPassword(BuildContext context) async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar(context, 'Please enter your email to reset your password.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar(context, 'Password reset email sent successfully!');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'Something went wrong. Please try again.';
      }
      _showSnackBar(context, message);
    }
  }

  /// Helper function to show a snackbar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
        padding: const EdgeInsets.fromLTRB(38, 60, 38, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            SizedBox(
              width: 400,
              height: 200,
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 60),

            // Heading
            const Text(
              "Reset Password",
              style: TextStyle(
                color: Color(0xFF00A889),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Email Input Field
            _buildTextField(
              controller: _emailController,
              labelText: "Email",
              isPassword: false,
            ),
            const SizedBox(height: 30),

            // Reset Password Button
            _buildActionButton(
              text: "Send Reset Email",
              onPressed: () => resetPassword(context),
            ),
            const SizedBox(height: 20),

            // Back to Login
            Text(
              "Remember your password?",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Go back!",
                style: TextStyle(
                  color: Color(0xFF00A889),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build a text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required bool isPassword,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFD9D9D9),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(
            color: Color(0xFF00A889),
            fontSize: 18,
          ),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(
              color: Color(0xFF00A889),
              fontSize: 14,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  /// Helper to build a button
  Widget _buildActionButton(
      {required String text, required VoidCallback onPressed}) {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF52D7BF),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
