import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/grade.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  bool _isLoading = true;
  List<dynamic> _grades = [];
  String _selectedTerm = 'term1';
  String _selectedYear = '2024-2025';
  final List<String> _terms = ['term1', 'term2', 'term3'];

  bool get _isAdmin => AuthService.role == 'admin' || AuthService.role == 'teacher';
  bool get _canManageGrades => _isAdmin;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);
    try {
      int? studentId;
      // Parents and students can only see their own grades
      if (!_isAdmin) {
        studentId = AuthService.userId;
      }

      final response = await apiService.getGrades(
        studentId: studentId,
        term: _selectedTerm,
        academicYear: _selectedYear,
      );
      setState(() => _grades = response);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load grades: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showGradeDialog() {
    final studentIdController = TextEditingController();
    final subjectIdController = TextEditingController();
    final classIdController = TextEditingController();
    final assignmentController = TextEditingController();
    final examController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Grade'),
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
                controller: subjectIdController,
                decoration: const InputDecoration(labelText: 'Subject ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: classIdController,
                decoration: const InputDecoration(labelText: 'Class ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: assignmentController,
                decoration: const InputDecoration(labelText: 'Assignment Score'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: examController,
                decoration: const InputDecoration(labelText: 'Exam Score'),
                keyboardType: TextInputType.number,
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
                'subject_id': int.tryParse(subjectIdController.text) ?? 0,
                'class_id': int.tryParse(classIdController.text) ?? 0,
                'term': _selectedTerm,
                'academic_year': _selectedYear,
                'assignment_score': double.tryParse(assignmentController.text),
                'exam_score': double.tryParse(examController.text),
              };

              try {
                await apiService.createGrade(data);
                Fluttertoast.showToast(
                  msg: 'Grade added successfully',
                  backgroundColor: Colors.green,
                );
                Navigator.pop(context);
                _loadGrades();
              } catch (e) {
                Fluttertoast.showToast(
                  msg: e.toString(),
                  backgroundColor: Colors.red,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGrades,
          ),
        ],
      ),
      floatingActionButton: _canManageGrades
          ? FloatingActionButton(
              onPressed: _showGradeDialog,
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
                  child: DropdownButtonFormField<String>(
                    value: _selectedTerm,
                    decoration: const InputDecoration(labelText: 'Term'),
                    items: _terms.map((term) {
                      return DropdownMenuItem(
                        value: term,
                        child: Text(term.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedTerm = value!);
                      _loadGrades();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Academic Year'),
                    controller: TextEditingController(text: _selectedYear),
                    onChanged: (value) {
                      _selectedYear = value;
                      _loadGrades();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _grades.isEmpty
                    ? const Center(child: Text('No grades found'))
                    : ListView.builder(
                        itemCount: _grades.length,
                        itemBuilder: (context, index) {
                          final grade = Grade.fromJson(_grades[index]);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              title: Text(grade.studentName),
                              subtitle: Text('${grade.subjectName} - ${grade.className}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${grade.totalScore?.toStringAsFixed(1) ?? '-'}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '/100',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
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
