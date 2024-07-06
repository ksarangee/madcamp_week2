import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _afterSuccess() async {
    try {
      User user = await UserApi.instance.me();
      print('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}'
          '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
          '\n이메일: ${user.kakaoAccount?.email}');
      await _sendUserInfoToServer(user);
      print('사용자 정보 서버 전송 성공');
      // 로그인 성공 시 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, '/home');
      print('홈 화면으로 이동');
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
  }

  Future<void> _sendUserInfoToServer(User user) async {
    final response = await http.post(
      Uri.parse('http:///kakao_login'), // 실제 서버 URL로 변경하세요
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'kakao_id': user.id,
        'nickname': user.kakaoAccount?.profile?.nickname,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send user info to server');
    } else {
      print('서버 응답: ${response.body}');
    }
  }

  Future<void> _signInWithKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        setState(() {
          _isLoading = true;
        });
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        await _afterSuccess();
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
        if (error is PlatformException && error.code == 'CANCELED') {
          setState(() {
            _isLoading = false;
          });
          return;
        }
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          await _afterSuccess();
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        setState(() {
          _isLoading = true;
        });
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
        await _afterSuccess();
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
    setState(() {
      _isLoading = false;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0CBB4),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '손 끝에서 시작되는\n지식의 조각들\n\n',
                    style: TextStyle(
                      color: Color(0xFF350B08),
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signInWithKakao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEEC981),
                      side: const BorderSide(color: Colors.brown, width: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Start with Kakao',
                      style: TextStyle(color: Color(0xFF350B08)),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: SvgPicture.asset(
                      'assets/icons/browse_icon.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
