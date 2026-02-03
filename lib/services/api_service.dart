import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  static String? _token;
  static String? _role;
  static int? _userId;

  // Getters
  static String? get token => _token;
  static String? get role => _role;
  static int? get userId => _userId;
  static bool get isAuthenticated => _token != null;

  // Set auth data
  static void setAuth(String token, String role, int userId) {
    _token = token;
    _role = role;
    _userId = userId;
  }

  // Clear auth data
  static void clearAuth() {
    _token = null;
    _role = null;
    _userId = null;
  }

  // Get headers with auth token
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Helper method for making GET requests
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$endpoint')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  // Helper method for making POST requests
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  // Helper method for making PUT requests
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  // Helper method for making DELETE requests
  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(uri, headers: _headers);
    return _handleResponse(response);
  }

  // Handle response and errors
  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        message: body['error'] ?? 'An error occurred',
        statusCode: response.statusCode,
      );
    }
  }

  // Auth methods
  Future<dynamic> login(String email, String password) async {
    final response = await post(ApiEndpoints.login, body: {
      'email': email,
      'password': password,
    });
    
    if (response['token'] != null) {
      setAuth(
        response['token'],
        response['user']['role'],
        response['user']['user_id'],
      );
    }
    return response;
  }

  Future<dynamic> register(Map<String, dynamic> userData) async {
    return await post(ApiEndpoints.register, body: userData);
  }

  Future<dynamic> getCurrentUser() async {
    return await get(ApiEndpoints.me);
  }

  // Dashboard
  Future<dynamic> getDashboardStats() async {
    return await get(ApiEndpoints.dashboard);
  }

  // Students
  Future<dynamic> getStudents({String? search, String? status, String? classId}) async {
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;
    if (status != null) queryParams['status'] = status;
    if (classId != null) queryParams['class_id'] = classId;
    
    return await get(ApiEndpoints.students, queryParams: queryParams.isEmpty ? null : queryParams);
  }

  Future<dynamic> getStudent(int id) async {
    return await get('${ApiEndpoints.students}/$id');
  }

  Future<dynamic> createStudent(Map<String, dynamic> studentData) async {
    return await post(ApiEndpoints.students, body: studentData);
  }

  Future<dynamic> updateStudent(int id, Map<String, dynamic> studentData) async {
    return await put('${ApiEndpoints.students}/$id', body: studentData);
  }

  Future<dynamic> deleteStudent(int id) async {
    return await delete('${ApiEndpoints.students}/$id');
  }

  // Teachers
  Future<dynamic> getTeachers() async {
    return await get(ApiEndpoints.teachers);
  }

  Future<dynamic> getTeacher(int id) async {
    return await get('${ApiEndpoints.teachers}/$id');
  }

  Future<dynamic> createTeacher(Map<String, dynamic> teacherData) async {
    return await post(ApiEndpoints.teachers, body: teacherData);
  }

  Future<dynamic> updateTeacher(int id, Map<String, dynamic> teacherData) async {
    return await put('${ApiEndpoints.teachers}/$id', body: teacherData);
  }

  Future<dynamic> deleteTeacher(int id) async {
    return await delete('${ApiEndpoints.teachers}/$id');
  }

  // Classes
  Future<dynamic> getClasses() async {
    return await get(ApiEndpoints.classes);
  }

  Future<dynamic> getClass(int id) async {
    return await get('${ApiEndpoints.classes}/$id');
  }

  Future<dynamic> createClass(Map<String, dynamic> classData) async {
    return await post(ApiEndpoints.classes, body: classData);
  }

  Future<dynamic> updateClass(int id, Map<String, dynamic> classData) async {
    return await put('${ApiEndpoints.classes}/$id', body: classData);
  }

  // Subjects
  Future<dynamic> getSubjects() async {
    return await get(ApiEndpoints.subjects);
  }

  Future<dynamic> createSubject(Map<String, dynamic> subjectData) async {
    return await post(ApiEndpoints.subjects, body: subjectData);
  }

  // Grades
  Future<dynamic> getGrades({int? studentId, int? classId, int? subjectId, String? academicYear, String? term}) async {
    final queryParams = <String, String>{};
    if (studentId != null) queryParams['student_id'] = studentId.toString();
    if (classId != null) queryParams['class_id'] = classId.toString();
    if (subjectId != null) queryParams['subject_id'] = subjectId.toString();
    if (academicYear != null) queryParams['academic_year'] = academicYear;
    if (term != null) queryParams['term'] = term;
    
    return await get(ApiEndpoints.grades, queryParams: queryParams.isEmpty ? null : queryParams);
  }

  Future<dynamic> getGradeReport(int studentId, {String? academicYear, String? term}) async {
    final queryParams = <String, String>{};
    if (academicYear != null) queryParams['academic_year'] = academicYear;
    if (term != null) queryParams['term'] = term;
    
    return await get('${ApiEndpoints.gradeReport}/$studentId', queryParams: queryParams.isEmpty ? null : queryParams);
  }

  Future<dynamic> createGrade(Map<String, dynamic> gradeData) async {
    return await post(ApiEndpoints.grades, body: gradeData);
  }

  // Attendance
  Future<dynamic> getAttendance({int? studentId, int? classId, String? startDate, String? endDate, String? status}) async {
    final queryParams = <String, String>{};
    if (studentId != null) queryParams['student_id'] = studentId.toString();
    if (classId != null) queryParams['class_id'] = classId.toString();
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (status != null) queryParams['status'] = status;
    
    return await get(ApiEndpoints.attendance, queryParams: queryParams.isEmpty ? null : queryParams);
  }

  Future<dynamic> getAttendanceSummary(int studentId, {String? academicYear}) async {
    final queryParams = <String, String>{};
    if (academicYear != null) queryParams['academic_year'] = academicYear;
    
    return await get('${ApiEndpoints.attendanceSummary}/$studentId', queryParams: queryParams.isEmpty ? null : queryParams);
  }

  Future<dynamic> recordAttendance(Map<String, dynamic> attendanceData) async {
    return await post(ApiEndpoints.attendance, body: attendanceData);
  }

  Future<dynamic> recordBulkAttendance(Map<String, dynamic> bulkData) async {
    return await post('${ApiEndpoints.attendance}/bulk', body: bulkData);
  }

  // Fees
  Future<dynamic> getFees({int? studentId, String? academicYear, String? status}) async {
    final queryParams = <String, String>{};
    if (studentId != null) queryParams['student_id'] = studentId.toString();
    if (academicYear != null) queryParams['academic_year'] = academicYear;
    if (status != null) queryParams['status'] = status;
    
    return await get(ApiEndpoints.fees, queryParams: queryParams.isEmpty ? null : queryParams);
  }

  Future<dynamic> createFee(Map<String, dynamic> feeData) async {
    return await post(ApiEndpoints.fees, body: feeData);
  }

  Future<dynamic> payFee(int feeId, double amount) async {
    return await put('${ApiEndpoints.fees}/$feeId/pay', body: {'paid_amount': amount});
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// Singleton instance
final apiService = ApiService();
