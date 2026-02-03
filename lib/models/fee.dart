class Fee {
  final int? feeId;
  final int studentId;
  final String feeType;
  final double amount;
  final double? paidAmount;
  final String paymentStatus;
  final String dueDate;
  final String academicYear;
  final String? studentFirstName;
  final String? studentLastName;
  final String? admissionNumber;
  final String? createdAt;

  Fee({
    this.feeId,
    required this.studentId,
    required this.feeType,
    required this.amount,
    this.paidAmount,
    required this.paymentStatus,
    required this.dueDate,
    required this.academicYear,
    this.studentFirstName,
    this.studentLastName,
    this.admissionNumber,
    this.createdAt,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      feeId: json['fee_id'],
      studentId: json['student_id'] ?? 0,
      feeType: json['fee_type'] ?? '',
      amount: json['amount'] != null 
          ? double.tryParse(json['amount'].toString()) ?? 0.0 
          : 0.0,
      paidAmount: json['paid_amount'] != null 
          ? double.tryParse(json['paid_amount'].toString()) 
          : null,
      paymentStatus: json['payment_status'] ?? '',
      dueDate: json['due_date'] ?? '',
      academicYear: json['academic_year'] ?? '',
      studentFirstName: json['first_name'],
      studentLastName: json['last_name'],
      admissionNumber: json['admission_number'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fee_id': feeId,
      'student_id': studentId,
      'fee_type': feeType,
      'amount': amount,
      'due_date': dueDate,
      'academic_year': academicYear,
    };
  }

  String get studentName => '${studentFirstName ?? ''} ${studentLastName ?? ''}'.trim();
  
  double get balance => amount - (paidAmount ?? 0);
  
  double get paymentPercentage => amount > 0 
      ? ((paidAmount ?? 0) / amount) * 100 
      : 0;
}

class DashboardStats {
  final int students;
  final int teachers;
  final int classes;
  final double pendingFees;
  final AttendanceStats attendanceToday;

  DashboardStats({
    required this.students,
    required this.teachers,
    required this.classes,
    required this.pendingFees,
    required this.attendanceToday,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      students: json['students'] ?? 0,
      teachers: json['teachers'] ?? 0,
      classes: json['classes'] ?? 0,
      pendingFees: json['pending_fees'] != null 
          ? double.tryParse(json['pending_fees'].toString()) ?? 0.0 
          : 0.0,
      attendanceToday: AttendanceStats.fromJson(json['attendance_today'] ?? {}),
    );
  }
}

class AttendanceStats {
  final int present;
  final int absent;

  AttendanceStats({
    required this.present,
    required this.absent,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }

  int get total => present + absent;
  double get attendanceRate => total > 0 ? (present / total) * 100 : 0;
}
