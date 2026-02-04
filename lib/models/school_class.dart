import 'student.dart';

class SchoolClass {
  final int? classId;
  final String className;
  final int gradeLevel;
  final int? classTeacherId;
  final String? teacherFirstName;
  final String? teacherLastName;
  final String academicYear;
  final List<Student>? students;
  final List<Subject>? subjects;
  final String? createdAt;

  SchoolClass({
    this.classId,
    required this.className,
    required this.gradeLevel,
    this.classTeacherId,
    this.teacherFirstName,
    this.teacherLastName,
    required this.academicYear,
    this.students,
    this.subjects,
    this.createdAt,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    var studentsList = <Student>[];
    if (json['students'] != null) {
      studentsList = (json['students'] as List)
          .map((s) => Student.fromJson(s))
          .toList();
    }

    var subjectsList = <Subject>[];
    if (json['subjects'] != null) {
      subjectsList = (json['subjects'] as List)
          .map((s) => Subject.fromJson(s))
          .toList();
    }

    return SchoolClass(
      classId: json['classId'] ?? json['class_id'] ?? 0,
      className: json['className'] ?? json['class_name'] ?? '',
      gradeLevel: json['gradeLevel'] ?? json['grade_level'] ?? 0,
      classTeacherId: json['classTeacherId'] ?? json['class_teacher_id'],
      teacherFirstName: json['teacherFirstName'] ?? json['teacher_first_name'],
      teacherLastName: json['teacherLastName'] ?? json['teacher_last_name'],
      academicYear: json['academicYear'] ?? json['academic_year'] ?? '',
      students: studentsList,
      subjects: subjectsList,
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_name': className,
      'grade_level': gradeLevel,
      'class_teacher_id': classTeacherId,
      'academic_year': academicYear,
    };
  }

  String get classTeacher => teacherFirstName != null && teacherLastName != null
      ? '$teacherFirstName $teacherLastName'
      : 'Not Assigned';
}

class Subject {
  final int? subjectId;
  final String subjectName;
  final String subjectCode;
  final String? description;
  final int? creditHours;

  Subject({
    this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    this.description,
    this.creditHours,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subject_id'],
      subjectName: json['subject_name'] ?? '',
      subjectCode: json['subject_code'] ?? '',
      description: json['description'],
      creditHours: json['credit_hours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
      'subject_code': subjectCode,
      'description': description,
      'credit_hours': creditHours,
    };
  }
}
