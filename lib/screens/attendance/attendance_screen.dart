import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/attendance.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isLoading = true;
  List<dynamic> _attendance = [];
  String _selectedStatus = '';
  DateTime? _selectedDate;
  final List<String> _statuses = ['', 'present', 'absent', 'late', 'excused'];

  bool get _isAdmin => AuthService.role == 'admin' || AuthService.role == 'teacher';
  bool get _canManageAttendance => _isAdmin;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    try {
      int? studentId;
      // Parents and students can only see their own attendance
      if (!_isAdmin) {
        studentId = AuthService.userId;
      }

      final response = await apiService.getAttendance(
        studentId: studentId,
        startDate: _selectedDate?.toIso8601String().split('T')[0],
        status: _selectedStatus.isEmpty ? null : _selectedStatus,
      );
      setState(() => _attendance = response);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load attendance: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAttendanceDialog() {
    final studentIdController = TextEditingController();
    final classIdController = TextEditingController();
    String selectedStatus = 'present';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Attendance'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentIdController,
                decoration: const InputDecoration(labelText: 'Student ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: classIdController,
                decoration: const InputDecoration(labelText: 'Class ID'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['present', 'absent', 'late', 'excused'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedStatus = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'student_id': int.tryParse(studentIdController.text) ?? 0,
                'class_id': int.tryParse(classIdController.text) ?? 0,
                'date': _selectedDate?.toIso8601String().split('T')[0] ?? '',
                'status': selectedStatus,
              };

              try {
                await apiService.recordAttendance(data);
                Fluttertoast.showToast(
                  msg: 'Attendance recorded successfully',
                  backgroundColor: Colors.green,
                );
                Navigator.pop(context);
                _loadAttendance();
              } catch (e) {
                Fluttertoast.showToast(
                  msg: e.toString(),
                  backgroundColor: Colors.red,
                );
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'excused':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendance,
          ),
        ],
      ),
      floatingActionButton: _canManageAttendance
          ? FloatingActionButton(
              onPressed: _showAttendanceDialog,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                        _loadAttendance();
                      }
                    },
                    child: Text(
                      'Date: ${_selectedDate?.toIso8601String().split('T')[0] ?? 'Select'}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: _statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.isEmpty ? 'All' : status.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedStatus = value ?? '');
                      _loadAttendance();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _attendance.isEmpty
                    ? const Center(child: Text('No attendance records found'))
                    : ListView.builder(
                        itemCount: _attendance.length,
                        itemBuilder: (context, index) {
                          final record = Attendance.fromJson(_attendance[index]);
                          final statusColor = _getStatusColor(record.status);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withOpacity(0.2),
                                child: Icon(
                                  record.status == 'present' ? Icons.check : Icons.close,
                                  color: statusColor,
                                ),
                              ),
                              title: Text(record.studentName),
                              subtitle: Text('${record.className} - ${record.date}'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  record.status.toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
