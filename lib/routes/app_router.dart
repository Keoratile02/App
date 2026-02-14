import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../views/profile_page_screen.dart';
import '../views/student_home_page.dart';
import '../auth/auth_page.dart';
import '../services/auth_service.dart';
import '../views/home_page.dart';
import '../views/student_register_screen.dart';
import '../views/admin_register_screen.dart';
import '../views/add_consultation_screen.dart';
import '../views/consultation_details_screen.dart';
import '../views/admin_dashboard_screen.dart';

class RouteManager {
  static const String wrapper = '/';
  static const String home = '/home';
  static const String studentRegister = '/studentRegister';
  static const String studentHome = '/studentHome';
  static const String adminRegister = '/adminRegister';
  static const String adminDashboard = '/adminDashboard';
  static const String authPage = '/auth';
  static const String addConsultation = '/addConsultation';
  static const String consultationDetails = '/consultationDetails';
  static const String studentProfile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('🧭 Navigating to: ${settings.name}');

    switch (settings.name) {
      case wrapper:
        return MaterialPageRoute(builder: (context) => const AuthWrapper());

      case home:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final email = args['email'] ?? 'unknown';
        return MaterialPageRoute(
          builder: (context) => HomeScreen(email: email),
        );

      case studentRegister:
        return MaterialPageRoute(builder: (context) => StudentRegisterScreen());

      case adminRegister:
        return MaterialPageRoute(
          builder: (context) => const AdminRegisterScreen(),
        );

      case studentHome:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final email = args['email'] ?? 'unknown@stud.cut.ac.za';
        return MaterialPageRoute(
          builder: (context) => StudentHomeScreen(email: email),
        );

      case adminDashboard:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final email = args['email'] ?? 'unknown@cut.ac.za';
        return MaterialPageRoute(
          builder: (context) => AdminDashboardScreen(email: email),
        );

      case authPage:
        return MaterialPageRoute(
          builder: (context) => const AuthPage(isLogin: true),
        );

      case addConsultation:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final existingBooking = args['existingBooking'];
        final bookingId = args['bookingId'];
        return MaterialPageRoute(
          builder:
              (context) => AddConsultationScreen(
                existingBooking: existingBooking,
                bookingId: bookingId,
              ),
        );

      case consultationDetails:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final consultation = args['consultation'] as Map<String, dynamic>;
        final bookingId = args['bookingId'] as String;
        final onDelete = args['onDelete'] as VoidCallback;
        return MaterialPageRoute(
          builder:
              (context) => ConsultationDetailsScreen(
                consultation: consultation,
                bookingId: bookingId,
                onDelete: onDelete,
              ),
        );

      case studentProfile:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final email = args['email'] ?? 'unknown@stud.cut.ac.za';
        return MaterialPageRoute(
          builder: (context) => ProfilePage(email: email),
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('404: Page not found')),
              ),
        );
    }
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _navigated = false; // To prevent multiple navigation attempts

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_navigated) return;

    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final role = authService.userRole;

    if (user != null && role != null) {
      _navigated = true;

      if (role == 'admin') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(
            context,
            RouteManager.adminDashboard,
            arguments: {'email': user.email ?? 'unknown@cut.ac.za'},
          );
        });
      } else if (role == 'student') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(
            context,
            RouteManager.studentHome,
            arguments: {'email': user.email ?? 'unknown@stud.cut.ac.za'},
          );
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => Scaffold(
                    body: Center(child: Text('Unknown user role: $role')),
                  ),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final role = authService.userRole;

    if (user == null) {
      return const AuthPage(isLogin: true);
    }

    if (role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // While waiting for navigation, show loading
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
