import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game title
              Text(
                'Gobble Up',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 60),

              // Difficulty label
              Text(
                '난이도',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30),

              // Difficulty buttons
              _buildDifficultyButton(
                context,
                '초급',
                AIDifficulty.easy,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildDifficultyButton(
                context,
                '중급',
                AIDifficulty.medium,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildDifficultyButton(
                context,
                '상급',
                AIDifficulty.hard,
                Colors.red,
              ),
              const SizedBox(height: 16),
              _buildDifficultyButton(
                context,
                '지옥',
                AIDifficulty.hell,
                Colors.purple[900]!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String label,
    AIDifficulty difficulty,
    Color color, {
    bool enabled = true,
  }) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: enabled
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      gameMode: GameMode.humanVsAI,
                      aiDifficulty: difficulty,
                    ),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? color : Colors.grey[400],
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
