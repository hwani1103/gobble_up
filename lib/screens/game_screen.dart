import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
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
            // Opponent's waiting area (top)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WaitingAreaWidget(
                player: controller.currentPlayer.opponent,
                pawns: controller.state.waitingArea[controller.currentPlayer.opponent] ?? [],
                isCurrentPlayer: false,
                selectedPawn: controller.selectedPawn,
                onPawnTap: controller.selectPawnFromWaiting,
              ),
            ),

            // Turn indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: winner != null
                  ? Container(
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
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: currentPlayer.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${currentPlayer.name}'s Turn",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: currentPlayer.color,
                          ),
                        ),
                      ],
                    ),
            ),

            // Game board
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: BoardWidget(controller: controller),
                ),
              ),
            ),

            // Current player's waiting area (bottom)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WaitingAreaWidget(
                player: controller.currentPlayer,
                pawns: controller.state.waitingArea[controller.currentPlayer] ?? [],
                isCurrentPlayer: true,
                selectedPawn: controller.selectedPawn,
                onPawnTap: controller.selectPawnFromWaiting,
              ),
            ),

            // Action buttons
            if (controller.selectedPawn != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: controller.cancelSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Cancel Selection'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
