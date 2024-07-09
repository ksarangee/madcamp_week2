// interest_posts_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/document.dart';
import '../screens/document_detail_screen.dart';
import '../secret.dart';

class InterestPostsScreen extends StatefulWidget {
  @override
  _InterestPostsScreenState createState() => _InterestPostsScreenState();
}

class _InterestPostsScreenState extends State<InterestPostsScreen> {
  List<Document> _documents = [];
  Map<String, List<Document>> _categoryDocuments = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInterestPosts();
  }

  String getCategoryName(int categoryId) {
    switch (categoryId) {
      case 1:
        return '역사';
      case 2:
        return '개발';
      case 3:
        return '엔터테인먼트';
      case 4:
        return '음식';
      case 5:
        return '일상';
      case 6:
        return '예술';
      default:
        return '기타';
    }
  }

  Future<void> _fetchInterestPosts() async {
    try {
      final userId = 3; // TODO: 실제 사용자 ID로 교체
      final response =
          await http.get(Uri.parse('$backendUrl/get_interests/$userId'));

      if (response.statusCode == 200) {
        List<dynamic> interests = jsonDecode(response.body);
        List<int> categoryIds =
            interests.map<int>((interest) => interest['id']).toList();
        print('Category IDs: $categoryIds'); // 디버그 로그

        final postsResponse = await http.get(Uri.parse('$backendUrl/posts'));
        if (postsResponse.statusCode == 200) {
          List<dynamic> allPosts = jsonDecode(postsResponse.body);
          print('All posts: $allPosts'); // 디버그 로그

          List<Document> interestPosts = allPosts
              .where((post) => categoryIds.contains(post['category']))
              .map((post) => Document.fromJson(post))
              .toList();
          print('Interest posts: ${interestPosts.length}'); // 디버그 로그

          Map<String, List<Document>> categoryDocuments = {};
          for (var doc in interestPosts) {
            String categoryName = getCategoryName(doc.categoryId);
            print(
                'Document ${doc.id}: Category ID ${doc.categoryId}, Category Name: $categoryName'); // 디버그 로그

            if (!categoryDocuments.containsKey(categoryName)) {
              categoryDocuments[categoryName] = [];
            }
            categoryDocuments[categoryName]!.add(doc);
          }

          setState(() {
            _categoryDocuments = categoryDocuments;
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load posts');
        }
      } else {
        throw Exception('Failed to load interests');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          AppBar(title: Text('My Interests'), backgroundColor: Colors.white),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _categoryDocuments.isEmpty
              ? Center(child: Text('No posts found for your interests.'))
              : ListView(
                  children: _categoryDocuments.entries.map((entry) {
                    String categoryName = entry.key;
                    List<Document> documents = entry.value;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(categoryName),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...documents.map((doc) {
                            return ListTile(
                              title: Text(doc.title),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DocumentDetailScreen(document: doc),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
    );
  }

  Color _getCategoryColor(String category) {
    // Define a color map or use random colors
    Map<String, Color> colorMap = {
      "역사": Color(0xFFF3CDCD),
      "개발": Color(0xFFC3DEF7),
      "엔터테인먼트": Color(0xFFB7E6B6),
      "음식": Color(0xFFF4DBB9),
      "일상": Color(0xFFCDC1F2),
      "예술": Color(0xFFB1EBEE),
    };
    return colorMap[category] ?? Colors.grey;
  }
}
