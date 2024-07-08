import 'package:flutter/material.dart';
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

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getString('accessToken') != null;

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // bool isLoggedIn = prefs.getString('accessToken') != null;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "IBMPlexSansKR",
        primaryColor: Color(0xFF42312A),
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialRoute: '/home', // 초기 경로를 로그인으로 설정
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
  int _currentIndex = 0;

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
        selectedIconTheme: IconThemeData(color: Color(0xFF42312A)),
        selectedLabelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF42312A)),
        showSelectedLabels: true, // 선택된 라벨 보이기/숨기기
        showUnselectedLabels: false, // 선택되지 않은 라벨 보이기/숨기기
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
