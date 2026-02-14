import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentLoginViewModel extends ChangeNotifier {
  String email = '';
  String password = '';
  bool isLoading = false;
  bool rememberMe = false;
  String? errorMessage;

  void updateForm(String email, String password) {
    this.email = email;
    this.password = password;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      isLoading = false;
      notifyListeners();

      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {'email': email},
      );
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = e.message;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${errorMessage ?? "Unknown error"}'),
        ),
      );
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email to reset password'),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/auth');
  }
}
