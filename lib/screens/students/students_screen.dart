import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/api_service.dart';
import '../../models/student.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  bool _isLoading = true;
  List<dynamic> _students = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final response = await apiService.getStudents(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
      setState(() => _students = response);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load students: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteStudent(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await apiService.deleteStudent(id);
      Fluttertoast.showToast(
        msg: 'Student deleted successfully',
        backgroundColor: Colors.green,
      );
      _loadStudents();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to delete: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  void _showStudentDialog({Student? student}) {
    final isEditing = student != null;
    final firstNameController = TextEditingController(text: student?.firstName ?? '');
    final lastNameController = TextEditingController(text: student?.lastName ?? '');
    final dobController = TextEditingController(text: student?.dateOfBirth ?? '');
    final admissionController = TextEditingController(text: student?.admissionNumber ?? '');
    final addressController = TextEditingController(text: student?.address ?? '');
    final phoneController = TextEditingController(text: student?.phone ?? '');

    showDialog(
      context: context,
      builder: (context) {
        String selectedGender = student?.gender ?? 'male';
        
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(isEditing ? 'Edit Student' : 'Add Student'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  TextField(
                    controller: dobController,
                    decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['male', 'female', 'other'].map((g) {
                      return DropdownMenuItem(value: g, child: Text(g.toUpperCase()));
                    }).toList(),
                    onChanged: (v) {
                      setState(() => selectedGender = v ?? 'male');
                    },
                  ),
                  TextField(
                    controller: admissionController,
                    decoration: const InputDecoration(labelText: 'Admission Number'),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
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
                    'first_name': firstNameController.text,
                    'last_name': lastNameController.text,
                    'date_of_birth': dobController.text,
                    'gender': selectedGender,
                    'admission_number': admissionController.text,
                    'date_admitted': DateTime.now().toIso8601String().split('T')[0],
                    'address': addressController.text,
                    'phone': phoneController.text,
                  };

                  try {
                    final studentId = student?.studentId ?? 0;
                    if (isEditing && studentId == 0) {
                      Fluttertoast.showToast(
                        msg: 'Error: Student ID is missing',
                        backgroundColor: Colors.red,
                      );
                      return;
                    }

                    if (isEditing) {
                      await apiService.updateStudent(studentId, data);
                      Fluttertoast.showToast(
                        msg: 'Student updated successfully',
                        backgroundColor: Colors.green,
                      );
                    } else {
                      await apiService.createStudent(data);
                      Fluttertoast.showToast(
                        msg: 'Student created successfully',
                        backgroundColor: Colors.green,
                      );
                    }
                    Navigator.pop(context);
                    _loadStudents();
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: e.toString(),
                      backgroundColor: Colors.red,
                    );
                  }
                },
                child: Text(isEditing ? 'Update' : 'Create'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search students',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadStudents();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _loadStudents(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(child: Text('No students found'))
                    : ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = Student.fromJson(_students[index]);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple[100],
                                child: Text(
                                  (student.firstName.isNotEmpty ? student.firstName[0] : '?') +
                                  (student.lastName.isNotEmpty ? student.lastName[0] : '?'),
                                  style: const TextStyle(color: Colors.deepPurple),
                                ),
                              ),
                              title: Text(student.fullName),
                              subtitle: Text(
                                '${student.admissionNumber} - ${student.className ?? 'Not assigned'}',
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showStudentDialog(student: student);
                                  } else if (value == 'delete') {
                                    _deleteStudent(student.studentId ?? 0);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
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
