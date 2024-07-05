import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../services/trend_service.dart';
import '../services/interest_service.dart';
import '../services/today_text_service.dart';
import '../services/random_service.dart';

class HomeScreen extends StatelessWidget {
  // Add a named key parameter to the constructor
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
    );
  }
}
