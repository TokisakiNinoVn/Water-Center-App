class Document {
  final int id;
  final String name;
  final String description;
  final String fileUrl;
  final String? createdAt;
  final String? updatedAt;
  final String uploadBy;

  Document({
    required this.id,
    required this.name,
    required this.description,
    required this.fileUrl,
    this.createdAt,
    this.updatedAt,
    required this.uploadBy,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      fileUrl: json['file_url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      uploadBy: json['upload_by'] ?? '',
    );
  }
}
