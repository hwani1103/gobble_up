import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/pawn.dart';
import 'pawn_widget.dart';

class WaitingAreaWidget extends StatelessWidget {
  final Player player;
  final List<Pawn> pawns;
  final bool isCurrentPlayer;
  final Pawn? selectedPawn;
  final Function(Pawn) onPawnTap;

  const WaitingAreaWidget({
    super.key,
    required this.player,
    required this.pawns,
    required this.isCurrentPlayer,
    this.selectedPawn,
    required this.onPawnTap,
  });

  @override
  Widget build(BuildContext context) {
    const pawnSize = 40.0; // Uniform size for all pawns in waiting area

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: player.color.withOpacity(0.1),
        border: Border.all(
          color: isCurrentPlayer ? player.color : Colors.grey,
          width: isCurrentPlayer ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Player name
          Text(
            '${player.name}:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isCurrentPlayer ? player.color : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 6),

          // Pawns in a single row
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: pawns.map((pawn) {
                final isSelected = selectedPawn == pawn;
                return GestureDetector(
                  onTap: isCurrentPlayer ? () => onPawnTap(pawn) : null,
                  child: Container(
                    width: pawnSize,
                    height: pawnSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: player.color,
                      border: isSelected
                          ? Border.all(color: Colors.yellow, width: 3)
                          : Border.all(color: Colors.black26, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 3,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        pawn.size.displayName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
