import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  String? _userRole; // admin, student, or unknown

  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      _currentUser = user;
      if (user != null) {
        // Fetch role from Firestore
        _userRole = await _fetchUserRole(user.uid);
      } else {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  String? get userRole => _userRole;

  // Async Firestore fetch role by uid
  Future<String> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['role'] != null) {
          return data['role'] as String;
        }
      }
      // fallback to email based role if no role stored in Firestore
      return getUserRoleByEmail(_currentUser?.email ?? '');
    } catch (e) {
      // On error, fallback to email-based role
      return getUserRoleByEmail(_currentUser?.email ?? '');
    }
  }

  // Determine role by email domain as fallback
  String getUserRoleByEmail(String email) {
    if (email.endsWith('@cut.ac.za')) {
      return 'admin';
    } else if (email.endsWith('@stud.cut.ac.za')) {
      return 'student';
    } else {
      return 'unknown';
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update role after login
      _userRole = await _fetchUserRole(userCredential.user!.uid);
      notifyListeners();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  Future<User?> register(
    String email,
    String password,
    String name,
    String studentId,
    String contact,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final appUser = AppUser(
        email: email,
        name: name,
        studentId: studentId,
        contact: contact,
        createdAt: DateTime.now(),
        role: getUserRoleByEmail(email), // Save role on registration
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(appUser.toFirestore());

      _userRole = appUser.role;
      notifyListeners();

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  String _authError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid CUT email address';
      case 'weak-password':
        return 'Password must be 8+ chars with @ symbol';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Incorrect password';
      default:
        return 'Authentication failed';
    }
  }

  Future<AppUser?> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }
}
