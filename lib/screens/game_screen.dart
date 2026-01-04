import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/player.dart';
import '../widgets/board_widget.dart';
import '../widgets/waiting_area_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(),
      child: const _GameScreenContent(),
    );
  }
}

class _GameScreenContent extends StatelessWidget {
  const _GameScreenContent();

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
                  isCurrentPlayer: currentPlayer == Player.player2,
                  selectedPawn: controller.selectedPawn,
                  onPawnTap: controller.selectPawnFromWaiting,
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
                    '${winner.name} Wins! 🎉',
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
                ),
              ),
            ),

            // Action buttons - fixed height to prevent grid resize
            SizedBox(
              height: 56,
              child: controller.selectedPawn != null
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
