class Document {
  final int id;
  final String? imageUrl;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;
  final int? todayViews; // 추가된 필드: 오늘의 조회수
  final int categoryId; //카데고리 id 필드 추가

  Document({
    required this.id,
    this.imageUrl,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.todayViews, // 생성자에 반영
    required this.categoryId,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image'], // imageUrl은 null일 수 있음
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      todayViews: json['today_views'] ?? 0, // 기본값 0 설정
      categoryId: json['category'] ?? 0,
    );
  }
}
