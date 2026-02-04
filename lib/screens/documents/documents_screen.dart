import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/api_service.dart';
import '../../services/api_config.dart';
import '../../services/auth_service.dart';
import '../../models/document.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _isLoading = true;
  List<dynamic> _documents = [];
  String _selectedCategory = '';
  final List<String> _categories = ['', 'general', 'report', 'notice', 'syllabus', 'exam', 'other'];

  bool get _isAdmin => AuthService.role == 'admin';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      final response = await apiService.getDocuments(
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
      );
      setState(() => _documents = response);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load documents: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadDocument() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const UploadDocumentDialog(),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await apiService.uploadDocument(
          result['filePath'] as String,
          result['title'] as String,
          description: result['description'] as String?,
          category: result['category'] as String?,
          isPublic: result['isPublic'] as bool?,
        );
        Fluttertoast.showToast(
          msg: 'Document uploaded successfully',
          backgroundColor: Colors.green,
        );
        _loadDocuments();
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Failed to upload document: ${e.toString()}',
          backgroundColor: Colors.red,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteDocument(Document doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${doc.title}"?'),
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
      await apiService.deleteDocument(doc.documentId!);
      Fluttertoast.showToast(
        msg: 'Document deleted successfully',
        backgroundColor: Colors.green,
      );
      _loadDocuments();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to delete: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _viewDocument(Document doc) async {
    final url = '$baseUrl${ApiEndpoints.documents}/${doc.documentId}/download';
    Fluttertoast.showToast(
      msg: 'Download URL: $url',
      backgroundColor: Colors.blue,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'report':
        return Colors.blue;
      case 'notice':
        return Colors.orange;
      case 'syllabus':
        return Colors.green;
      case 'exam':
        return Colors.red;
      case 'other':
        return Colors.grey;
      default:
        return Colors.deepPurple;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'report':
        return Icons.description;
      case 'notice':
        return Icons.notifications;
      case 'syllabus':
        return Icons.menu_book;
      case 'exam':
        return Icons.assignment;
      case 'other':
        return Icons.insert_drive_file;
      default:
        return Icons.file_present;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _uploadDocument,
              child: const Icon(Icons.upload),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((category) {
                String display = category.isEmpty ? 'All' : category[0].toUpperCase() + category.substring(1);
                return DropdownMenuItem(
                  value: category,
                  child: Text(display),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value ?? '');
                _loadDocuments();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _documents.isEmpty
                    ? const Center(child: Text('No documents found'))
                    : ListView.builder(
                        itemCount: _documents.length,
                        itemBuilder: (context, index) {
                          final doc = Document.fromJson(_documents[index]);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getCategoryColor(doc.category).withOpacity(0.2),
                                child: Icon(
                                  _getCategoryIcon(doc.category),
                                  color: _getCategoryColor(doc.category),
                                ),
                              ),
                              title: Text(doc.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(doc.categoryDisplay),
                                  Text('${doc.formattedFileSize} • ${doc.uploadedByEmail ?? 'Unknown'}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'view') {
                                    _viewDocument(doc);
                                  } else if (value == 'delete' && _isAdmin) {
                                    _deleteDocument(doc);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'view', child: Text('View/Download')),
                                  if (_isAdmin)
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

class UploadDocumentDialog extends StatefulWidget {
  const UploadDocumentDialog({super.key});

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'general';
  bool _isPublic = true;
  String _filePath = '';

  final List<String> _categories = ['general', 'report', 'notice', 'syllabus', 'exam', 'other'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    // In a real app, use file_picker package
    // For now, we'll simulate file selection
    Fluttertoast.showToast(
      msg: 'File selection would open here (use file_picker package)',
      backgroundColor: Colors.orange,
    );
    setState(() {
      _filePath = '/path/to/selected/file.pdf';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Document'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category[0].toUpperCase() + category.substring(1)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value ?? 'general');
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Public Document'),
              subtitle: const Text('Visible to all users'),
              value: _isPublic,
              onChanged: (value) {
                setState(() => _isPublic = value);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selectFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_filePath.isEmpty ? 'Select PDF File' : 'File Selected'),
            ),
            if (_filePath.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _filePath.split('/').last,
                  style: TextStyle(color: Colors.grey[600]),
                ),
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
          onPressed: () {
            if (_titleController.text.isEmpty) {
              Fluttertoast.showToast(
                msg: 'Please enter a title',
                backgroundColor: Colors.red,
              );
              return;
            }
            Navigator.pop(context, {
              'title': _titleController.text,
              'description': _descriptionController.text,
              'category': _selectedCategory,
              'isPublic': _isPublic,
              'filePath': _filePath,
            });
          },
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
