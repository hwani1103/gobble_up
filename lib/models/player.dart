import 'package:flutter/material.dart';

enum Player {
  player1,
  player2;

  Player get opponent => this == Player.player1 ? Player.player2 : Player.player1;

  Color get color => this == Player.player1 ? Colors.blue : Colors.red;

  String get name => this == Player.player1 ? 'Player 1' : 'Player 2';
}
