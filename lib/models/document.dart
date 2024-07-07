class Document {
  final int id;
  final String? imageUrl;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;

  Document({
    required this.id,
    this.imageUrl,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? 0,
      imageUrl: json['image'] ?? '',
      title: json['title'] ?? 'No Title',
      content: json['content'] ?? 'No Content',
      createdAt: json['created_at'] ?? 'Unknown',
      updatedAt: json['updated_at'] ?? 'Unknown',
    );
  }
}
