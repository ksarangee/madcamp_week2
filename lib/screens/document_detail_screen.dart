import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // intl 패키지 임포트
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

  Future<void> _reportPost(String reason) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/report_post'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'post_id': _document.id,
          'user_id': userId,
          'report_reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('신고가 접수되었습니다.')),
        );
      } else {
        print('Failed to report post');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('신고에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('Error reporting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('신고 중 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  void _showReportPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedReason;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('신고'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('스팸'),
                    leading: Radio<String>(
                      value: '스팸',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('부적절한 콘텐츠'),
                    leading: Radio<String>(
                      value: '부적절한 콘텐츠',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('허위 정보'),
                    leading: Radio<String>(
                      value: '허위 정보',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('기타'),
                    leading: Radio<String>(
                      value: '기타',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedReason != null) {
                      _reportPost(selectedReason!); // 신고 내용을 전송
                      Navigator.of(context).pop(); // 팝업을 닫음
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('신고 사유를 선택해주세요.')),
                      );
                    }
                  },
                  child: Text('제출'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 팝업을 닫음
                  },
                  child: Text('취소'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 한국 표준시(KST)로 변환된 날짜와 시간 형식화 함수
  String _formatDateTimeKST(String dateTimeString) {
    final dateFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", "en_US");
    final utcDateTime = dateFormat.parse(dateTimeString, true).toUtc();
    final kstDateTime = utcDateTime.add(Duration(hours: 9)); // UTC+9 시간대 적용
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(kstDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.report),
            onPressed: _showReportPopup,
          ),
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
                await _fetchDocument();
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
                        Center(
                          // 추가
                          child: Text(
                            _document.title,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center, // 추가
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        if (_document.imageUrl != null &&
                            _document.imageUrl!.isNotEmpty)
                          Center(
                            // 추가
                            child: Image.network(_document.imageUrl!),
                          ),
                        const SizedBox(height: 16.0),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(_document.categoryId),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            getCategoryName(_document.categoryId),
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(_document.content,
                            style: const TextStyle(fontSize: 18.0)),
                        const SizedBox(height: 16.0),
                        Text(
                            '최근 수정 시각: ${_formatDateTimeKST(_document.updatedAt)}',
                            style: const TextStyle(fontSize: 14.0)),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('좋아요: $likes'),
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
                                Text('싫어요: $dislikes'),
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
                        const Text('댓글:',
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
                            hintText: '댓글을 입력하세요',
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

  Color _getCategoryColor(int categoryId) {
    switch (categoryId) {
      case 1:
        return Color(0xFFF3CDCD);
      case 2:
        return Color(0xFFC3DEF7);
      case 3:
        return Color(0xFFB7E6B6);
      case 4:
        return Color(0xFFF4DBB9);
      case 5:
        return Color(0xFFCDC1F2);
      case 6:
        return Color(0xFFB1EBEE);
      default:
        return Colors.grey[200]!;
    }
  }
}
