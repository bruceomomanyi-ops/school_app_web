import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/api_service.dart';
import '../../models/school_class.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  bool _isLoading = true;
  List<dynamic> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    try {
      final response = await apiService.getClasses();
      setState(() => _classes = response);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load classes: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showClassDialog({SchoolClass? schoolClass}) {
    final isEditing = schoolClass != null;
    final nameController = TextEditingController(text: schoolClass?.className ?? '');
    final gradeController = TextEditingController(
      text: schoolClass?.gradeLevel.toString() ?? '',
    );
    final yearController = TextEditingController(
      text: schoolClass?.academicYear ?? '2024-2025',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Class' : 'Add Class'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Class Name'),
              ),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(labelText: 'Grade Level'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Academic Year'),
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
                'class_name': nameController.text,
                'grade_level': int.tryParse(gradeController.text) ?? 1,
                'academic_year': yearController.text,
              };

              try {
                if (isEditing) {
                  await apiService.updateClass(schoolClass!.classId!, data);
                  Fluttertoast.showToast(
                    msg: 'Class updated successfully',
                    backgroundColor: Colors.green,
                  );
                } else {
                  await apiService.createClass(data);
                  Fluttertoast.showToast(
                    msg: 'Class created successfully',
                    backgroundColor: Colors.green,
                  );
                }
                Navigator.pop(context);
                _loadClasses();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClasses,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClassDialog(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? const Center(child: Text('No classes found'))
              : ListView.builder(
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final schoolClass = SchoolClass.fromJson(_classes[index]);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          child: Text(
                            schoolClass.gradeLevel.toString(),
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                        title: Text(schoolClass.className),
                        subtitle: Text('Grade ${schoolClass.gradeLevel} - ${schoolClass.academicYear}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showClassDialog(schoolClass: schoolClass);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
