class Document {
  final int? documentId;
  final String title;
  final String? description;
  final String filePath;
  final int fileSize;
  final String category;
  final int uploadedBy;
  final bool isPublic;
  final String? createdAt;
  final String? uploadedByEmail;

  Document({
    this.documentId,
    required this.title,
    this.description,
    required this.filePath,
    required this.fileSize,
    required this.category,
    required this.uploadedBy,
    required this.isPublic,
    this.createdAt,
    this.uploadedByEmail,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      documentId: json['document_id'] ?? json['documentId'],
      title: json['title'] ?? '',
      description: json['description'],
      filePath: json['file_path'] ?? json['filePath'] ?? '',
      fileSize: json['file_size'] ?? json['fileSize'] ?? 0,
      category: json['category'] ?? 'general',
      uploadedBy: json['uploaded_by'] ?? json['uploadedBy'] ?? 0,
      isPublic: json['is_public'] ?? json['isPublic'] ?? true,
      createdAt: json['created_at'] ?? json['createdAt'],
      uploadedByEmail: json['uploaded_by_email'] ?? json['uploadedByEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'title': title,
      'description': description,
      'file_path': filePath,
      'file_size': fileSize,
      'category': category,
      'uploaded_by': uploadedBy,
      'is_public': isPublic,
      'created_at': createdAt,
    };
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get categoryDisplay {
    switch (category.toLowerCase()) {
      case 'report':
        return 'Report';
      case 'notice':
        return 'Notice';
      case 'syllabus':
        return 'Syllabus';
      case 'exam':
        return 'Exam';
      case 'other':
        return 'Other';
      default:
        return 'General';
    }
  }

  bool get isPdf => filePath.toLowerCase().endsWith('.pdf');
}
