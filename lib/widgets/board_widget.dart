import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../models/board.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  final GameController controller;

  const BoardWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final board = controller.board;
    final winningLine = board.getWinningLine();

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final row = index ~/ 3;
            final col = index % 3;
            final position = Position(row, col);
            final cell = board.getCell(position);

            final isWinningCell = winningLine?.any(
                  (pos) => pos.row == row && pos.col == col,
                ) ??
                false;

            final canPlaceHere = controller.selectedPawn != null &&
                controller.canPlacePawn(position);

            return CellWidget(
              cell: cell,
              position: position,
              isWinningCell: isWinningCell,
              canPlaceHere: canPlaceHere,
              onTap: () {
                if (canPlaceHere) {
                  controller.selectDestination(position);
                }
              },
              onPawnTap: () {
                controller.selectPawnFromBoard(position);
              },
            );
          },
        ),
      ),
    );
  }
}
