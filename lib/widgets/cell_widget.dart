import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../models/board.dart';
import 'pawn_widget.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final Position position;
  final bool isWinningCell;
  final bool canPlaceHere;
  final VoidCallback? onTap;
  final VoidCallback? onPawnTap;

  const CellWidget({
    super.key,
    required this.cell,
    required this.position,
    this.isWinningCell = false,
    this.canPlaceHere = false,
    this.onTap,
    this.onPawnTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isWinningCell
              ? Colors.green.withOpacity(0.3)
              : Colors.grey[200],
          border: Border.all(
            color: Colors.grey[400]!,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (cell.topPawn != null)
              GestureDetector(
                onTap: onPawnTap,
                child: PawnWidget(
                  pawn: cell.topPawn!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
