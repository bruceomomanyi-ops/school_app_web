import 'package:flutter/material.dart';
import 'package:school_app_web/screens/auth/login_screen.dart';
import 'package:school_app_web/screens/auth/register_screen.dart';
import 'package:school_app_web/screens/dashboard/dashboard_screen.dart';
import 'package:school_app_web/screens/students/students_screen.dart';
import 'package:school_app_web/screens/teachers/teachers_screen.dart';
import 'package:school_app_web/screens/classes/classes_screen.dart';
import 'package:school_app_web/screens/grades/grades_screen.dart';
import 'package:school_app_web/screens/attendance/attendance_screen.dart';
import 'package:school_app_web/screens/fees/fees_screen.dart';
import 'package:school_app_web/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/students': (context) => const StudentsScreen(),
        '/teachers': (context) => const TeachersScreen(),
        '/classes': (context) => const ClassesScreen(),
        '/grades': (context) => const GradesScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/fees': (context) => const FeesScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await AuthService.init();
    final isLoggedIn = await AuthService.isLoggedIn();

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _isAuthenticated = isLoggedIn;
      });
    }

    // Navigate based on auth state
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isAuthenticated) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
