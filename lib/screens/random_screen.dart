import 'package:flutter/material.dart';

class RandomScreen extends StatelessWidget {
  const RandomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Screen'),
      ),
      body: const Center(
        child: Text('This is the Random Screen'),
      ),
    );
  }
}
