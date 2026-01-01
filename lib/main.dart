import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const GobbleUpApp());
}

class GobbleUpApp extends StatelessWidget {
  const GobbleUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GobbleUp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
