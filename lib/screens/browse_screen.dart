import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../secret.dart';  // secret.dart 파일을 임포트합니다.

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  BrowseScreenState createState() => BrowseScreenState();
}

class BrowseScreenState extends State<BrowseScreen> {
  static const String serverPort = '80'; // 서버 포트 번호
  static const String endpoint = '/posts'; // 서버 엔드포인트 경로

  Future<List<Document>> _fetchDocuments() async {
    final response = await http.get(Uri.parse('$backendUrl:$serverPort$endpoint'));

    print('Server Response: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((doc) => Document.fromJson(doc)).toList();
    } else {
      throw Exception('Failed to load documents');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse')),
      body: FutureBuilder<List<Document>>(
        future: _fetchDocuments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중 화면
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(
                child: Text('Error: ${snapshot.error}')); // 데이터 로딩 중 에러 발생 시 화면
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No documents found')); // 데이터 없을 때 화면
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final document = snapshot.data![index];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(document.title,
                          style: const TextStyle(fontSize: 18.0)),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          Text('User: ${document.userId}',
                              style: const TextStyle(fontSize: 14.0)),
                          const Spacer(),
                          Text('Created: ${document.createdAt}',
                              style: const TextStyle(fontSize: 14.0)),
                          Text('  Updated: ${document.updatedAt}',
                              style: const TextStyle(fontSize: 14.0)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DocumentDetailScreen(document: document),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class DocumentDetailScreen extends StatelessWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${document.userId}',
                style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 8.0),
            Text(document.content, style: const TextStyle(fontSize: 18.0)),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Text('Created at: ${document.createdAt}'),
                const Spacer(),
                Text('Updated at: ${document.updatedAt}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Document {
  final int id;
  final String userId;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;

  Document({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 'Unknown',
      title: json['title'] ?? 'No Title',
      content: json['content'] ?? 'No Content',
      createdAt: json['created_at'] ?? 'Unknown',
      updatedAt: json['updated_at'] ?? 'Unknown',
    );
  }
}
