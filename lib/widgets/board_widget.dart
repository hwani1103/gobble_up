import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../models/board.dart';
import '../models/game_state.dart';
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

            // Check if this cell contains the selected pawn
            final isSelectedPosition = controller.selectedPosition != null &&
                controller.selectedPosition == position;

            return CellWidget(
              cell: cell,
              position: position,
              isWinningCell: isWinningCell,
              canPlaceHere: canPlaceHere,
              isSelected: isSelectedPosition,
              onTap: () {
                // If already selecting a pawn, this is destination
                if (controller.phase == GamePhase.selectingDestination) {
                  controller.selectDestination(position);
                }
                // If no pawn selected and cell has pawn, select it
                else if (cell.topPawn != null) {
                  controller.selectPawnFromBoard(position);
                }
              },
              onPawnTap: () {
                // Not used anymore - handled in onTap
              },
            );
          },
        ),
      ),
    );
  }
}
