class Student {
  final int? studentId;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String admissionNumber;
  final String dateAdmitted;
  final int? classId;
  final String? className;
  final int? gradeLevel;
  final String? address;
  final String? phone;
  final String? status;
  final int? parentId;
  final String? parentEmail;
  final String? createdAt;

  Student({
    this.studentId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.admissionNumber,
    required this.dateAdmitted,
    this.classId,
    this.className,
    this.gradeLevel,
    this.address,
    this.phone,
    this.status,
    this.parentId,
    this.parentEmail,
    this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      admissionNumber: json['admission_number'] ?? '',
      dateAdmitted: json['date_admitted'] ?? '',
      classId: json['class_id'],
      className: json['class_name'],
      gradeLevel: json['grade_level'],
      address: json['address'],
      phone: json['phone'],
      status: json['status'],
      parentId: json['parent_user_id'] ?? json['parent_id'],
      parentEmail: json['parent_email'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'admission_number': admissionNumber,
      'date_admitted': dateAdmitted,
      'class_id': classId,
      'address': address,
      'phone': phone,
      'status': status,
    };
  }

  String get fullName => '$firstName $lastName';
}
