import 'package:flutter/material.dart';
import 'package:flutter_application_1/secret.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
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
      Uri.parse('$backendUrl/kakao_login'), // 실제 서버 URL로 변경하세요
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.01,
                  left: 0,
                  right: 0,
                  child: const Column(
                    children: [
                      Text(
                        '손 끝에서 시작되는\n지식의 조각들,',
                        style: TextStyle(
                          color: Color(0xFF350B08),
                          fontSize: 32,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8), //위 text와 간격
                      Text(
                        'tidbits',
                        style: TextStyle(
                          color: Color(0xFF350B08),
                          fontSize: 40,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3, // 여기를 추가
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _signInWithKakao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEEC981),
                        side: const BorderSide(color: Colors.brown, width: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text(
                        'Start with Kakao',
                        style: TextStyle(
                            color: Color(0xFF350B08), fontFamily: 'NotoSansKR'),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/below_cookie.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
    );
  }
}
