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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: player.color.withOpacity(0.1),
        border: Border.all(
          color: isCurrentPlayer ? player.color : Colors.grey.shade300,
          width: isCurrentPlayer ? 5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: pawns.map((pawn) {
                final isSelected = selectedPawn == pawn;
                return GestureDetector(
                  onTap: isCurrentPlayer ? () => onPawnTap(pawn) : null,
                  child: Container(
                    width: pawn.size.waitingAreaSize,
                    height: pawn.size.waitingAreaSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: player.color,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.black26,
                        width: isSelected ? 4 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 3,
                          offset: const Offset(1, 1),
                        ),
                      ],
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
