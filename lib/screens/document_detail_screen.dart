import 'package:flutter/material.dart';
import '../models/document.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../secret.dart'; // backendUrl을 포함
import 'edit_document_screen.dart';

class DocumentDetailScreen extends StatefulWidget {
  final Document document;

  const DocumentDetailScreen({Key? key, required this.document})
      : super(key: key);

  @override
  _DocumentDetailScreenState createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  late Document _document;
  int likes = 0;
  int dislikes = 0;
  bool hasLiked = false;
  bool hasDisliked = false;
  List<String> comments = [];
  TextEditingController commentController = TextEditingController();
  bool _isLoading = true; // 로딩 상태를 나타내는 변수
  final int userId = 3; // 실제 사용자 ID로 대체

  @override
  void initState() {
    super.initState();
    _document = widget.document;
    Future.microtask(() async {
      await _incrementPostView();
      await _fetchDocument();
      await _fetchReactions();
      await _fetchComments();
      if (mounted) {
        setState(() {
          _isLoading = false; // 데이터 로드 완료 후 로딩 상태 해제
        });
      }
    });
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  // 서버에서 조회수 증가시키기
  Future<void> _incrementPostView() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/post/${_document.id}/view'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode != 204) {
        // 에러 처리
        print('Failed to increment post view');
      }
    } catch (e) {
      print('Error incrementing post view: $e');
    }
  }

  // 서버에서 최신 문서 가져오기
  Future<void> _fetchDocument() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/posts/${_document.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _document = Document.fromJson(data);
          });
        }
      } else {
        // 에러 처리
        print('Failed to fetch document');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  // 서버에서 현재 좋아요/싫어요 수 및 사용자 반응 가져오기
  Future<void> _fetchReactions() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/reactions/${_document.id}/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            likes = data['likes'];
            dislikes = data['dislikes'];
            hasLiked = data['user_reaction'] == 'like';
            hasDisliked = data['user_reaction'] == 'dislike';
          });
        }
      } else {
        // 에러 처리
        print('Failed to fetch reactions');
      }
    } catch (e) {
      print('Error fetching reactions: $e');
    }
  }

  // 서버에서 모든 댓글 가져오기
  Future<void> _fetchComments() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/comments/${_document.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            comments = List<String>.from(
                data.map((comment) => comment['comment_text']));
          });
        }
      } else {
        // 에러 처리
        print('Failed to fetch comments');
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  Future<void> _reactToPost(String reaction) async {
    if ((reaction == 'like' && hasLiked) ||
        (reaction == 'dislike' && hasDisliked)) {
      await _removeReaction(reaction);
    } else {
      if (hasLiked || hasDisliked) {
        await _removeReaction(hasLiked ? 'like' : 'dislike');
      }
      await _addReaction(reaction);
    }
  }

  Future<void> _removeReaction(String reaction) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/remove_reaction'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'post_id': _document.id,
          'user_id': userId,
          'content': reaction,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            if (reaction == 'like') {
              hasLiked = false;
              likes--;
            } else if (reaction == 'dislike') {
              hasDisliked = false;
              dislikes--;
            }
          });
        }
      } else {
        // 에러 처리
        print('Failed to remove reaction');
      }
    } catch (e) {
      print('Error removing reaction: $e');
    }
  }

  Future<void> _addReaction(String reaction) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/react_post'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'post_id': _document.id,
          'user_id': userId,
          'content': reaction,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            if (reaction == 'like') {
              hasLiked = true;
              hasDisliked = false;
              likes++;
            } else if (reaction == 'dislike') {
              hasLiked = false;
              hasDisliked = true;
              dislikes++;
            }
          });
        }
      } else {
        // 에러 처리
        print('Failed to react to post');
      }
    } catch (e) {
      print('Error reacting to post: $e');
    }
  }

  Future<void> _addComment() async {
    if (commentController.text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/comment_post'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'post_id': _document.id,
          'user_id': userId,
          'content': commentController.text,
        }),
      );

      if (response.statusCode == 200) {
        commentController.clear();
        // 댓글 추가 후 댓글 목록을 새로고침합니다.
        await _fetchComments();
      } else {
        // 에러 처리
        print('Failed to add comment');
      }
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(_document.title),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final editedDocument = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDocumentScreen(document: _document),
                ),
              );
              if (editedDocument != null) {
                setState(() {
                  _document = editedDocument;
                });
                // 수정된 문서 정보로 화면 갱신
                await _fetchDocument(); // 최신 문서 정보 가져오기
                _fetchReactions();
                _fetchComments();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_document.imageUrl != null &&
                            _document.imageUrl!.isNotEmpty)
                          Center(
                            child: Image.network(_document.imageUrl!),
                          ),
                        const SizedBox(height: 16.0),
                        Text(_document.content,
                            style: const TextStyle(fontSize: 18.0)),
                        const SizedBox(height: 16.0),
                        Text('Updated at: ${_document.updatedAt}',
                            style: const TextStyle(fontSize: 14.0)),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('Likes: $likes'),
                                IconButton(
                                  icon: Icon(
                                    hasLiked
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    color: hasLiked ? Colors.blue : null,
                                  ),
                                  onPressed: () => _reactToPost('like'),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Dislikes: $dislikes'),
                                IconButton(
                                  icon: Icon(
                                    hasDisliked
                                        ? Icons.thumb_down
                                        : Icons.thumb_down_outlined,
                                    color: hasDisliked ? Colors.red : null,
                                  ),
                                  onPressed: () => _reactToPost('dislike'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        const Text('Comments:',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(comments[index]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _addComment,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
