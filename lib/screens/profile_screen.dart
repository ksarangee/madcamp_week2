import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
<<<<<<< HEAD
import 'package:http/http.dart' as http; // http 패키지 추가
import 'dart:convert'; // json 디코딩을 위해 추가
=======
>>>>>>> 1d2ad0f1b7ef70acd7c2b04c538a476f7270c244

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> interests = ["역사", "개발", "엔터테인먼트", "음식", "일상", "예술"];
  List<String> selectedInterests = [];

  @override
  void initState() {
    super.initState();
    _loadInterests();
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
    //예시: await _saveInterestsToServer();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('관심 분야가 저장되었습니다.'),
    ));
    Navigator.of(context).pop(); // 다이얼로그 닫기
  }

  /* 관심 분야 저장 로직 예시:
  Future<void> _saveInterestsToServer() async {
  // 선택된 관심 분야를 category_id로 변환하는 로직 (예시)
  List<int> categoryIds = selectedInterests.map((interest) {
    return interests.indexOf(interest) + 1; // 카테고리 ID는 1부터 시작한다고 가정
  }).toList();

  // 서버로 보낼 데이터 구성
  var data = json.encode({"categories": categoryIds});

  // 서버 요청 URL 설정
  var url = Uri.parse('https://example.com/api/categories'); // 실제 서버 URL로 변경해야 함

  // POST 요청 보내기
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: data,
  );

  // 서버 응답 확인 (필요 시 오류 처리)
  if (response.statusCode == 200) {
    // 저장 성공
  } else {
    // 오류 처리
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('관심 분야 저장에 실패했습니다.'),
    ));
  }
}

  */

  void _toggleInterest(List<String> tempSelectedInterests, String interest) {
    setState(() {
      if (tempSelectedInterests.contains(interest)) {
        tempSelectedInterests.remove(interest);
      } else {
        tempSelectedInterests.add(interest);
      }
    });
  }

  void _logout() {
    //로그아웃 로직 구현해야함

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('로그아웃 되었습니다.'),
    ));
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // 모든 저장된 데이터 초기화
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('프로필'),
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
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

class LikedPostsScreen extends StatelessWidget {
  const LikedPostsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> likedPosts = [];
    // 서버에서 좋아요한 글 목록을 받아오는 로직을 구현해야함

    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 좋아요 한 글'),
      ),
      body: ListView.builder(
        itemCount: likedPosts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(likedPosts[index]),
          );
        },
=======
        title: Text('Profile'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _logout(context),
          child: Text('Logout'),
        ),
>>>>>>> 1d2ad0f1b7ef70acd7c2b04c538a476f7270c244
      ),
    );
  }
}
