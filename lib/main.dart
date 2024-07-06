import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secret.dart';  // secret.dart 파일을 임포트합니다.
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
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
