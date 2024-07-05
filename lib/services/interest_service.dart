import 'package:flutter/material.dart';
import '../screens/interest_screen.dart';

class InterestService {
  static void performAction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InterestScreen()),
    );
  }
}
