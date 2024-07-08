import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK 임포트
import 'package:http/http.dart' as http; // http 패키지 추가
import 'dart:convert'; // json 디코딩을 위해 추가
import '../models/document.dart';
import 'document_detail_screen.dart'; // DocumentDetailScreen 임포트

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> interests = ["역사", "개발", "엔터테인먼트", "음식", "일상", "예술"];
  List<String> selectedInterests = [];
  String userNickname = ''; //사용자 닉네임을 저장할 변수

  @override
  void initState() {
    super.initState();
    _loadInterests();
    _loadUserNickname();
  }

  Future<void> _loadUserNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userNickname = prefs.getString('userNickname') ?? '사용자'; // 저장된 닉네임 불러오기
    });
  }

  Future<void> _loadInterests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedInterests = prefs.getStringList('selectedInterests') ?? [];
    });
  }

  Future<void> _saveInterests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedInterests', selectedInterests);

    // 서버에 저장할 로직 호출
    await _saveInterestsToServer();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('관심 분야가 저장되었습니다.'),
    ));
    Navigator.of(context).pop(); // 다이얼로그 닫기
  }

  Future<void> _saveInterestsToServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // int? userId = prefs.getInt('userId'); // 유저 ID를 SharedPreferences에서 가져옵니다.
    int? userId = 3; // 임시로 3로 설정
    if (userId == null) return;

    final response = await http.post(
      Uri.parse('http://172.10.7.100/save_interests'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'interests': selectedInterests,
      }),
    );

    if (response.statusCode == 200) {
      print('Interests saved successfully');
    } else {
      print('Failed to save interests');
    }
  }

  void _toggleInterest(List<String> tempSelectedInterests, String interest) {
    setState(() {
      if (tempSelectedInterests.contains(interest)) {
        tempSelectedInterests.remove(interest);
      } else {
        tempSelectedInterests.add(interest);
      }
    });
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await UserApi.instance.unlink(); // 카카오 연결 해제
    } catch (error) {
      print('카카오 연결 해제 실패: $error');
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 모든 저장된 데이터 초기화
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userNickname님 반가워요!'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('관심 분야 설정 및 수정'),
            onTap: () {
              List<String> tempSelectedInterests = List.from(selectedInterests);

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('관심 분야를 선택하세요'),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return SingleChildScrollView(
                          child: Column(
                            children: interests.map((interest) {
                              return CheckboxListTile(
                                title: Text(interest),
                                value: tempSelectedInterests.contains(interest),
                                onChanged: (bool? value) {
                                  setState(() {
                                    _toggleInterest(
                                        tempSelectedInterests, interest);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedInterests = tempSelectedInterests;
                          });
                          _saveInterests();
                        },
                        child: const Text('저장'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('내가 좋아요 한 글'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LikedPostsScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('로그아웃'),
            onTap: () {
              _logout(context); // 이 부분을 변경
            },
          ),
        ],
      ),
    );
  }
}

class LikedPostsScreen extends StatefulWidget {
  const LikedPostsScreen({Key? key}) : super(key: key);

  @override
  _LikedPostsScreenState createState() => _LikedPostsScreenState();
}

class _LikedPostsScreenState extends State<LikedPostsScreen> {
  List<Map<String, dynamic>> likedPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchLikedPosts();
  }

  Future<void> _fetchLikedPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = 3; // 임시로 3으로 설정, 실제로는 SharedPreferences에서 가져옴
    if (userId == null) return;

    final response = await http.get(
      Uri.parse('http://172.10.7.100/liked_posts/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        likedPosts = List<Map<String, dynamic>>.from(data.map((post) => {
              'id': post['id'],
              'title': post['title'],
              'content': post['content'],
              'image': post['image'],
              'category_id': post['category_id'],
              'created_at': post['created_at'],
              'updated_at': post['updated_at'],
            }));
      });
    } else {
      print('Failed to fetch liked posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 좋아요 한 글'),
      ),
      body: ListView.builder(
        itemCount: likedPosts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(likedPosts[index]['title']),
            subtitle: Text(likedPosts[index]['content']),
            onTap: () {
              // DocumentDetailScreen으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocumentDetailScreen(
                    document: Document(
                      id: likedPosts[index]['id'],
                      title: likedPosts[index]['title'],
                      content: likedPosts[index]['content'],
                      imageUrl: likedPosts[index]['image'],
                      createdAt: likedPosts[index]['created_at'] ?? '',
                      updatedAt: likedPosts[index]['updated_at'] ?? '',
                      todayViews: likedPosts[index]['today_views'] ?? 0,
                      categoryId: likedPosts[index]['category_id'] ?? 0,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
