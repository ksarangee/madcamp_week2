import 'package:flutter/material.dart';
import '../screens/today_text_screen.dart';

class TodayTextService {
  static void performAction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TodayTextScreen()),
    );
  }
}
