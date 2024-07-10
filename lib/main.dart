import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secret.dart'; // secret.dart 파일을 임포트합니다.
import 'screens/login_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: kakaoApiKey);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarBrightness: Brightness.dark,
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "IBMPlexSansKR",
        primaryColor: Colors.black,
        useMaterial3: true,
      ),
      home: AnimatedSplashScreen(
        splash: Transform.scale(
          scale: 2.2,
          child: Image.asset(
            'assets/images/tidbitslogo.png',
            fit: BoxFit.contain,
            //width: MediaQuery.of(context).size.width * 0.8,
          ),
        ), // 여기에서 원하는 스플래시 아이콘이나 이미지를 사용하세요.
        nextScreen: FutureBuilder<bool>(
          future: checkLoginStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data!) {
              return const MyHomePage();
            } else {
              return const LoginScreen();
            }
          },
        ),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.white,
        duration: 1500,
      ),
      //initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 1; // 초기값을 홈 화면의 인덱스로 설정

  final List<Widget> _pages = [
    const BrowseScreen(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    try {
      await UserApi.instance.unlink(); // 카카오 연결 해제
    } catch (error) {
      print('카카오 연결 해제 실패: $error');
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 저장된 모든 데이터 초기화
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedIconTheme: const IconThemeData(color: Colors.black),
        selectedLabelStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
        selectedItemColor: Colors.black,
        showSelectedLabels: true, // 선택된 라벨 보이기
        showUnselectedLabels: false, // 선택되지 않은 라벨 숨기기
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/browse_icon.svg'),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/home_icon.svg'),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/profile_icon.svg'),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
