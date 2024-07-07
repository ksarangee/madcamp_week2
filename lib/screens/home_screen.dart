import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/custom_button.dart';
import '../services/trend_service.dart';
import '../services/interest_service.dart';
import '../services/today_text_service.dart';
import '../services/random_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> quotes = [
    {'quote': '"우리는 그 어떤 것에 대해서\n1억 분의 1도 모른다."', 'author': '- 토마스 에디슨'},
    {'quote': '"쓸데 없는 지식에서도\n큰 기쁨을 얻을 수 있다."', 'author': '- 버트런드 러셀'},
    {'quote': '"아는 것이 힘이다."', 'author': '- 프랜시스 베이컨'},
  ];

  int currentQuoteIndex = 0;
  bool isVisible = true;
  Timer? _timer; //Timer 변수

  @override
  void initState() {
    super.initState();
    _startQuoteAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 취소
    super.dispose();
  }

  void _startQuoteAnimation() {
    _timer = Timer.periodic(Duration(seconds: 6), (timer) {
      if (mounted) {
        // mounted 체크 추가
        setState(() {
          isVisible = false;
        });

        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            // mounted 체크 추가
            setState(() {
              currentQuoteIndex = (currentQuoteIndex + 1) % quotes.length;
              isVisible = true;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 100, // 명언을 위한 고정 높이
                child: AnimatedOpacity(
                  opacity: isVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quotes[currentQuoteIndex]['quote']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        quotes[currentQuoteIndex]['author']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    CustomButton(
                      text: 'Trend',
                      onPressed: () => TrendService.performAction(context),
                    ),
                    CustomButton(
                      text: 'Interest',
                      onPressed: () => InterestService.performAction(context),
                    ),
                    CustomButton(
                      text: 'Today\'s Text',
                      onPressed: () => TodayTextService.performAction(context),
                    ),
                    CustomButton(
                      text: 'Random',
                      onPressed: () => RandomService.performAction(context),
                      icon: Icons.refresh,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}