class FileModel {
  final String? id;
  final String filename;
  final String? description;
  final String username;
  final DateTime uploadDate;
  final String? fileUrl;

  // ✅ New field only used during upload
  final String? path;

  const FileModel({
    this.id,
    required this.filename,
    this.description,
    required this.username,
    required this.uploadDate,
    this.fileUrl,
    this.path, // ✅ Optional, won't affect existing usage
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['_id'],
      filename: json['filename'] ?? 'Untitled',
      description: json['description'],
      username: json['username'] ?? 'Unknown',
      uploadDate: json['uploadDate'] != null
          ? DateTime.parse(json['uploadDate'])
          : DateTime.now(),
      fileUrl: json['fileUrl'],
      path: null, // ✅ Safe default for backend responses
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'description': description,
      'username': username,
      'uploadDate': uploadDate.toIso8601String(),
      'fileUrl': fileUrl,
      // ❌ Don't include `path` in toJson—it’s local-only
    };
  }
}