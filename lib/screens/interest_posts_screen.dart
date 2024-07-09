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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInterestPosts();
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

        final postsResponse = await http.get(Uri.parse('$backendUrl/posts'));
        if (postsResponse.statusCode == 200) {
          List<dynamic> allPosts = jsonDecode(postsResponse.body);
          List<Document> interestPosts = allPosts
              .where((post) => categoryIds.contains(post['category']))
              .map((post) => Document.fromJson(post))
              .toList();

          setState(() {
            _documents = interestPosts;
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
          : ListView.builder(
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_documents[index].title),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DocumentDetailScreen(document: _documents[index]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
