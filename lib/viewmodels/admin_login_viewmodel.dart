import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLoginViewModel extends ChangeNotifier {
  String email = '';
  String password = '';
  bool isLoading = false;
  String? errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update form fields
  void updateForm(String newEmail, String newPassword) {
    email = newEmail;
    password = newPassword;
    notifyListeners();
  }

  // Admin login logic
  Future<void> loginAdmin(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Firebase Auth login
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Check if user is in 'admins' collection
      final doc =
          await _firestore.collection('admins').doc(userCred.user!.uid).get();
      if (!doc.exists || doc.data()?['isAdmin'] != true) {
        throw FirebaseAuthException(
          code: 'not-admin',
          message: 'This account is not authorized as admin.',
        );
      }

      // Navigate to admin dashboard
      Navigator.pushReplacementNamed(context, '/adminDashboard');
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Authentication error.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $errorMessage')));
    } catch (e) {
      errorMessage = 'Unexpected error occurred.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $errorMessage')));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Logout method
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/auth');
  }
}
