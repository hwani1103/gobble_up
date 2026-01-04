import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import '../widgets/board_widget.dart';
import '../widgets/waiting_area_widget.dart';

class GameScreen extends StatelessWidget {
  final GameMode gameMode;
  final AIDifficulty? aiDifficulty;

  const GameScreen({
    super.key,
    this.gameMode = GameMode.humanVsHuman,
    this.aiDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = GameController(
          gameMode: gameMode,
          aiDifficulty: aiDifficulty,
        );
        // Trigger AI move if AI starts first (though in our case, Player 1 always starts)
        return controller;
      },
      child: _GameScreenContent(
        gameMode: gameMode,
        aiDifficulty: aiDifficulty,
      ),
    );
  }
}

class _GameScreenContent extends StatelessWidget {
  final GameMode gameMode;
  final AIDifficulty? aiDifficulty;

  const _GameScreenContent({
    this.gameMode = GameMode.humanVsHuman,
    this.aiDifficulty,
  });

  String _getPlayerName(Player player) {
    if (gameMode == GameMode.aiVsAI) {
      return player == Player.player1 ? 'AI 1' : 'AI 2';
    }
    if (gameMode == GameMode.humanVsAI && player == Player.player2) {
      return aiDifficulty?.displayName ?? 'AI';
    }
    return player == Player.player1 ? 'Player' : 'Player 2';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final currentPlayer = controller.currentPlayer;
    final winner = controller.winner;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('GobbleUp'),
        backgroundColor: currentPlayer.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.resetGame();
            },
            tooltip: 'New Game',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Player 2's waiting area (top - always Player 2) - Fixed height
            SizedBox(
              height: 110,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: WaitingAreaWidget(
                  player: Player.player2,
                  pawns: controller.state.waitingArea[Player.player2] ?? [],
                  isCurrentPlayer: currentPlayer == Player.player2 &&
                      !controller.isAITurn,
                  selectedPawn: controller.selectedPawn,
                  onPawnTap: controller.selectPawnFromWaiting,
                  displayName: _getPlayerName(Player.player2),
                  isThinking: controller.isAIThinking &&
                      (gameMode == GameMode.aiVsAI || currentPlayer == Player.player2),
                ),
              ),
            ),

            // Winner indicator (only shown when game is over)
            if (winner != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: winner.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    winner == Player.player1
                        ? 'Player Wins! 🎉'
                        : '${_getPlayerName(Player.player2)} Wins! 🎉',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Game board - fixed size
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: BoardWidget(controller: controller),
                ),
              ),
            ),

            // Player 1's waiting area (bottom - always Player 1) - Fixed height
            SizedBox(
              height: 110,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: WaitingAreaWidget(
                  player: Player.player1,
                  pawns: controller.state.waitingArea[Player.player1] ?? [],
                  isCurrentPlayer: currentPlayer == Player.player1,
                  selectedPawn: controller.selectedPawn,
                  onPawnTap: controller.selectPawnFromWaiting,
                  displayName: _getPlayerName(Player.player1),
                  isThinking: controller.isAIThinking &&
                      gameMode == GameMode.aiVsAI &&
                      currentPlayer == Player.player1,
                ),
              ),
            ),

            // Action buttons - fixed height to prevent grid resize
            SizedBox(
              height: 56,
              child: controller.selectedPawn != null && !controller.isAITurn
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: controller.cancelSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('선택 취소'),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
