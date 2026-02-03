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
      initialRoute: '/login',
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
