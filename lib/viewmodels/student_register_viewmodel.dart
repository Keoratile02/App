import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class StudentRegisterViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final studentIdController = TextEditingController();
  final contactController = TextEditingController();
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

  bool isFormValid() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.endsWith('@stud.cut.ac.za')) return 'Must use student email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password required';
    if (value.length < 8) return 'Password too short';
    if (!value.contains('@')) return 'Must contain @ symbol';
    return null;
  }

  String? validateField(String? value, String label) {
    return (value == null || value.isEmpty) ? '$label is required' : null;
  }

  Future<bool> registerStudent() async {
    setError(null);

    if (!isFormValid()) return false;

    setLoading(true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final student = AppUser(
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        studentId: studentIdController.text.trim(),
        contact: contactController.text.trim(),
        createdAt: DateTime.now(),
        role: 'student',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(student.toFirestore());

      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      switch (e.code) {
        case 'email-already-in-use':
          setError('Email already in use');
          break;
        case 'invalid-email':
          setError('Invalid email');
          break;
        case 'weak-password':
          setError('Weak password');
          break;
        default:
          setError('Registration failed');
      }
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    studentIdController.dispose();
    contactController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
