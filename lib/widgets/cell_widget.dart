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
            color: canPlaceHere ? Colors.green : Colors.grey[400]!,
            width: canPlaceHere ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (canPlaceHere)
              Icon(
                Icons.add_circle_outline,
                color: Colors.green.withOpacity(0.5),
                size: 40,
              ),
            if (cell.topPawn != null)
              GestureDetector(
                onTap: onPawnTap,
                child: PawnWidget(
                  pawn: cell.topPawn!,
                ),
              ),
            if (cell.stack.length > 1)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${cell.stack.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
