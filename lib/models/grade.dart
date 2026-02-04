import 'student.dart';

class Grade {
  final int? gradeId;
  final int studentId;
  final int subjectId;
  final int classId;
  final int? teacherId;
  final String academicYear;
  final String term;
  final double? assignmentScore;
  final double? examScore;
  final double? totalScore;
  final String? studentFirstName;
  final String? studentLastName;
  final String? admissionNumber;
  final String? subjectName;
  final String? subjectCode;
  final String? className;
  final String? teacherFirstName;
  final String? teacherLastName;
  final String? createdAt;

  Grade({
    this.gradeId,
    required this.studentId,
    required this.subjectId,
    required this.classId,
    this.teacherId,
    required this.academicYear,
    required this.term,
    this.assignmentScore,
    this.examScore,
    this.totalScore,
    this.studentFirstName,
    this.studentLastName,
    this.admissionNumber,
    this.subjectName,
    this.subjectCode,
    this.className,
    this.teacherFirstName,
    this.teacherLastName,
    this.createdAt,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      gradeId: json['gradeId'] ?? json['grade_id'],
      studentId: json['studentId'] ?? json['student_id'] ?? 0,
      subjectId: json['subjectId'] ?? json['subject_id'] ?? 0,
      classId: json['classId'] ?? json['class_id'] ?? 0,
      teacherId: json['teacherId'] ?? json['teacher_id'],
      academicYear: json['academicYear'] ?? json['academic_year'] ?? '',
      term: json['term'] ?? '',
      assignmentScore: json['assignmentScore'] ?? json['assignment_score'] != null 
          ? double.tryParse((json['assignmentScore'] ?? json['assignment_score']).toString()) 
          : null,
      examScore: json['examScore'] ?? json['exam_score'] != null 
          ? double.tryParse((json['examScore'] ?? json['exam_score']).toString()) 
          : null,
      totalScore: json['totalScore'] ?? json['total_score'] != null 
          ? double.tryParse((json['totalScore'] ?? json['total_score']).toString()) 
          : null,
      studentFirstName: json['studentFirstName'] ?? json['first_name'],
      studentLastName: json['studentLastName'] ?? json['last_name'],
      admissionNumber: json['admissionNumber'] ?? json['admission_number'],
      subjectName: json['subjectName'] ?? json['subject_name'],
      subjectCode: json['subjectCode'] ?? json['subject_code'],
      className: json['className'] ?? json['class_name'],
      teacherFirstName: json['teacherFirstName'] ?? json['teacher_first_name'],
      teacherLastName: json['teacherLastName'] ?? json['teacher_last_name'],
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grade_id': gradeId,
      'student_id': studentId,
      'subject_id': subjectId,
      'class_id': classId,
      'teacher_id': teacherId,
      'academic_year': academicYear,
      'term': term,
      'assignment_score': assignmentScore,
      'exam_score': examScore,
    };
  }

  String get studentName => '${studentFirstName ?? ''} ${studentLastName ?? ''}';
  String get teacherName => '${teacherFirstName ?? ''} ${teacherLastName ?? ''}'.trim();
}

class GradeReport {
  final Student student;
  final String academicYear;
  final String term;
  final List<Grade> grades;
  final GradeSummary summary;

  GradeReport({
    required this.student,
    required this.academicYear,
    required this.term,
    required this.grades,
    required this.summary,
  });

  factory GradeReport.fromJson(Map<String, dynamic> json) {
    var gradesList = <Grade>[];
    if (json['grades'] != null) {
      gradesList = (json['grades'] as List)
          .map((g) => Grade.fromJson(g))
          .toList();
    }

    return GradeReport(
      student: Student.fromJson(json['student'] ?? {}),
      academicYear: json['academic_year'] ?? '',
      term: json['term'] ?? '',
      grades: gradesList,
      summary: GradeSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class GradeSummary {
  final int totalSubjects;
  final double averageScore;
  final double highestScore;
  final double lowestScore;

  GradeSummary({
    required this.totalSubjects,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
  });

  factory GradeSummary.fromJson(Map<String, dynamic> json) {
    return GradeSummary(
      totalSubjects: json['total_subjects'] ?? 0,
      averageScore: json['average_score'] != null 
          ? double.tryParse(json['average_score'].toString()) ?? 0.0 
          : 0.0,
      highestScore: json['highest_score']?.toDouble() ?? 0.0,
      lowestScore: json['lowest_score']?.toDouble() ?? 0.0,
    );
  }
}
