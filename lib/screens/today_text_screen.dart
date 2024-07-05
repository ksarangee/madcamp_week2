import 'package:flutter/material.dart';

class TodayTextScreen extends StatelessWidget {
  const TodayTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today Text Screen'),
      ),
      body: const Center(
        child: Text('This is the Today Text Screen'),
      ),
    );
  }
}
