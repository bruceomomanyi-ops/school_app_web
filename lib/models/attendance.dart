class Attendance {
  final int? attendanceId;
  final int studentId;
  final int classId;
  final String date;
  final String status;
  final String? remarks;
  final String? studentFirstName;
  final String? studentLastName;
  final String? admissionNumber;
  final String? className;
  final String? createdAt;

  Attendance({
    this.attendanceId,
    required this.studentId,
    required this.classId,
    required this.date,
    required this.status,
    this.remarks,
    this.studentFirstName,
    this.studentLastName,
    this.admissionNumber,
    this.className,
    this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceId: json['attendance_id'],
      studentId: json['student_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      remarks: json['remarks'],
      studentFirstName: json['first_name'],
      studentLastName: json['last_name'],
      admissionNumber: json['admission_number'],
      className: json['class_name'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'student_id': studentId,
      'class_id': classId,
      'date': date,
      'status': status,
      'remarks': remarks,
    };
  }

  String get studentName => '${studentFirstName ?? ''} ${studentLastName ?? ''}'.trim();
}

class AttendanceSummary {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int excusedDays;
  final double attendancePercentage;

  AttendanceSummary({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.excusedDays,
    required this.attendancePercentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalDays: json['total_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      excusedDays: json['excused_days'] ?? 0,
      attendancePercentage: json['attendance_percentage'] != null 
          ? double.tryParse(json['attendance_percentage'].toString()) ?? 0.0 
          : 0.0,
    );
  }
}

class BulkAttendanceRecord {
  final int studentId;
  final String status;
  final String? remarks;

  BulkAttendanceRecord({
    required this.studentId,
    required this.status,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'status': status,
      'remarks': remarks,
    };
  }
}
