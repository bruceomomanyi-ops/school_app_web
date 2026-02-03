class User {
  final int? userId;
  final String email;
  final String role;
  final int? linkedStudentId;
  final String? createdAt;

  User({
    this.userId,
    required this.email,
    required this.role,
    this.linkedStudentId,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      linkedStudentId: json['linked_student_id'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'role': role,
      'linked_student_id': linkedStudentId,
      'created_at': createdAt,
    };
  }
}

class AuthResponse {
  final String message;
  final String? token;
  final User? user;

  AuthResponse({
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
