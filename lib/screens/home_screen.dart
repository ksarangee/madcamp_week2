import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../services/trend_service.dart';
import '../services/interest_service.dart';
import '../services/today_text_service.dart';
import '../services/random_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20), // 상단 여백 추가
              const Text(
                '"우리는 그 어떤 것에 대해서\n1억 분의 1도 모른다."',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                '- 토마스 에디슨',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50), // 명언과 버튼 사이의 공간
              Expanded(
                //flex: 2, // GridView에 더 많은 공간 할당
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
