class File {
  final String? id;
  final String filename;
  final String? description;
  final String username; // MongoDB ObjectId as string
  final DateTime uploadDate;

  const File({
    this.id,
    required this.filename,
    this.description,
    required this.username,
    required this.uploadDate,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      id: json['_id'],
      filename: json['filename'],
      description: json['description'],
      username: json['username'],
      uploadDate: DateTime.parse(json['uploadDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'description': description,
      'username': username,
      'uploadDate': uploadDate.toIso8601String(),
    };
  }
}