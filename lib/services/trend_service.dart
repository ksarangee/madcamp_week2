import 'package:flutter/material.dart';
import '../screens/trend_screen.dart';

class TrendService {
  static void performAction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrendScreen()),
    );
  }
}
