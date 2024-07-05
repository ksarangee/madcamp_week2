import 'package:flutter/material.dart';
import '../screens/random_screen.dart';

class RandomService {
  static void performAction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RandomScreen()),
    );
  }
}
