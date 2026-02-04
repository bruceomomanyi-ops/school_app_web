import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/api_service.dart';
import '../../models/teacher.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  bool _isLoading = true;
  List<dynamic> _teachers = [];

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() => _isLoading = true);
    try {
      final response = await apiService.getTeachers();
      setState(() => _teachers = response);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load teachers: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showTeacherDialog({Teacher? teacher}) {
    final isEditing = teacher != null;
    final firstNameController = TextEditingController(text: teacher?.firstName ?? '');
    final lastNameController = TextEditingController(text: teacher?.lastName ?? '');
    final emailController = TextEditingController(text: teacher?.email ?? '');
    final phoneController = TextEditingController(text: teacher?.phone ?? '');
    final specializationController = TextEditingController(text: teacher?.subjectSpecialization ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Teacher' : 'Add Teacher'),
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
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: specializationController,
                decoration: const InputDecoration(labelText: 'Subject Specialization'),
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
                'email': emailController.text,
                'phone': phoneController.text,
                'subject_specialization': specializationController.text,
              };

              try {
                if (isEditing) {
                  await apiService.updateTeacher(teacher!.teacherId!, data);
                  Fluttertoast.showToast(
                    msg: 'Teacher updated successfully',
                    backgroundColor: Colors.green,
                  );
                } else {
                  await apiService.createTeacher(data);
                  Fluttertoast.showToast(
                    msg: 'Teacher created successfully',
                    backgroundColor: Colors.green,
                  );
                }
                Navigator.pop(context);
                _loadTeachers();
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
  }

  Future<void> _deleteTeacher(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: const Text('Are you sure you want to delete this teacher?'),
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
      await apiService.deleteTeacher(id);
      Fluttertoast.showToast(
        msg: 'Teacher deleted successfully',
        backgroundColor: Colors.green,
      );
      _loadTeachers();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to delete: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeachers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTeacherDialog(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _teachers.isEmpty
              ? const Center(child: Text('No teachers found'))
              : ListView.builder(
                  itemCount: _teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = Teacher.fromJson(_teachers[index]);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: Text(
                            (teacher.firstName.isNotEmpty ? teacher.firstName[0] : '?') +
                            (teacher.lastName.isNotEmpty ? teacher.lastName[0] : '?'),
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                        title: Text(teacher.fullName),
                        subtitle: Text(teacher.email),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showTeacherDialog(teacher: teacher);
                            } else if (value == 'delete') {
                              _deleteTeacher(teacher.teacherId!);
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
    );
  }
}
