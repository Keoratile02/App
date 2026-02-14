import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminRegisterViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    if (!value.endsWith('@cut.ac.za')) {
      return 'Email must end with @cut.ac.za';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains('@')) {
      return 'Password must contain @ symbol';
    }
    return null;
  }

  Future<bool> registerAdmin() async {
    setError(null);

    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    setLoading(true);

    try {
      // Firebase register
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      switch (e.code) {
        case 'email-already-in-use':
          setError('Email already in use');
          break;
        case 'invalid-email':
          setError('Invalid email address');
          break;
        case 'weak-password':
          setError('Weak password');
          break;
        default:
          setError('Registration failed: ${e.message}');
      }
      return false;
    } catch (e) {
      setLoading(false);
      setError('An unexpected error occurred');
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
