class Teacher {
  final int? teacherId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String subjectSpecialization;
  final String? hireDate;
  final double? salary;
  final String? status;
  final List<TeacherAssignment>? assignments;
  final String? createdAt;

  Teacher({
    this.teacherId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.subjectSpecialization,
    this.hireDate,
    this.salary,
    this.status,
    this.assignments,
    this.createdAt,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    var assignmentsList = <TeacherAssignment>[];
    if (json['assignments'] != null) {
      assignmentsList = (json['assignments'] as List)
          .map((a) => TeacherAssignment.fromJson(a))
          .toList();
    }

    return Teacher(
      teacherId: json['teacherId'] ?? json['teacher_id'] ?? 0,
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      subjectSpecialization: json['subjectSpecialization'] ?? json['subject_specialization'] ?? '',
      hireDate: json['hireDate'] ?? json['hire_date'],
      salary: json['salary'] != null ? double.tryParse(json['salary'].toString()) : null,
      status: json['status'],
      assignments: assignmentsList,
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacherId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'subject_specialization': subjectSpecialization,
      'hire_date': hireDate,
      'salary': salary,
      'status': status,
    };
  }

  String get fullName => '$firstName $lastName';
}

class TeacherAssignment {
  final int? assignmentId;
  final int teacherId;
  final int subjectId;
  final int classId;
  final String academicYear;
  final String? subjectName;
  final String? subjectCode;
  final String? className;

  TeacherAssignment({
    this.assignmentId,
    required this.teacherId,
    required this.subjectId,
    required this.classId,
    required this.academicYear,
    this.subjectName,
    this.subjectCode,
    this.className,
  });

  factory TeacherAssignment.fromJson(Map<String, dynamic> json) {
    return TeacherAssignment(
      assignmentId: json['assignmentId'] ?? json['assignment_id'],
      teacherId: json['teacherId'] ?? json['teacher_id'] ?? 0,
      subjectId: json['subjectId'] ?? json['subject_id'] ?? 0,
      classId: json['classId'] ?? json['class_id'] ?? 0,
      academicYear: json['academicYear'] ?? json['academic_year'] ?? '',
      subjectName: json['subjectName'] ?? json['subject_name'],
      subjectCode: json['subjectCode'] ?? json['subject_code'],
      className: json['className'] ?? json['class_name'],
    );
  }
}
