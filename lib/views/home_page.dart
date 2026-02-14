import 'package:firebase_flutter/views/admin_dashboard_screen.dart';
import 'package:firebase_flutter/views/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.userRole == null) {
      // Role not yet loaded, show loading
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authService.userRole == 'admin') {
      return AdminDashboardScreen(email: email);
    } else if (authService.userRole == 'student') {
      return StudentHomeScreen(email: email);
    } else {
      // Unknown role fallback
      return Scaffold(
        body: Center(child: Text('Unknown role for user: $email')),
      );
    }
  }
}
