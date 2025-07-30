import 'package:flutter/material.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro Timer')),
      body: const Center(
        child: Text('Pomodoro Screen - Placeholder'),
      ),
    );
  }
}
