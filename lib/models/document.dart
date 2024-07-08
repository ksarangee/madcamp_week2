class Document {
  final int id;
  final String? imageUrl;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;
  final int todayViews; // 추가된 필드: 오늘의 조회수
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
      id: json['id'] ?? 0,
      imageUrl: json['image'] ?? '',
      title: json['title'] ?? 'No Title',
      content: json['content'] ?? 'No Content',
      createdAt: json['created_at'] ?? 'Unknown',
      updatedAt: json['updated_at'] ?? 'Unknown',
      todayViews: json['today_views'] ??
          0, // JSON에서 'today_views' 필드를 가져와서 todayViews에 할당
      categoryId:
          json['category_id'] ?? 0, //JSON에서 'category'필드 가져와서 categoryId에 할당
    );
  }
}
