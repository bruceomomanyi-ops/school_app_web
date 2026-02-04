// API Configuration
// Change this to your Node.js backend URL
const String baseUrl = 'https://school-api-2g81.onrender.com/api';

// API Endpoints
class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  
  static const String students = '/students';
  static const String teachers = '/teachers';
  static const String classes = '/classes';
  static const String subjects = '/subjects';
  static const String assignments = '/assignments';
  static const String grades = '/grades';
  static const String attendance = '/attendance';
  static const String fees = '/fees';
  static const String dashboard = '/dashboard/stats';
  static const String gradeReport = '/grades/report';
  static const String attendanceSummary = '/attendance/summary';
  static const String documents = '/documents';
}
