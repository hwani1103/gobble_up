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
    // Group pawns by size
    final largePawns = pawns.where((p) => p.size == PawnSize.large).toList();
    final mediumPawns = pawns.where((p) => p.size == PawnSize.medium).toList();
    final smallPawns = pawns.where((p) => p.size == PawnSize.small).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: player.color.withOpacity(0.1),
        border: Border.all(
          color: isCurrentPlayer ? player.color : Colors.grey,
          width: isCurrentPlayer ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: player.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                player.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCurrentPlayer ? player.color : Colors.grey[600],
                ),
              ),
              if (isCurrentPlayer) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.green, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _buildPawnRow('Large', largePawns),
          const SizedBox(height: 8),
          _buildPawnRow('Medium', mediumPawns),
          const SizedBox(height: 8),
          _buildPawnRow('Small', smallPawns),
        ],
      ),
    );
  }

  Widget _buildPawnRow(String label, List<Pawn> pawns) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        ...pawns.map((pawn) {
          final isSelected = selectedPawn == pawn;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PawnWidget(
              pawn: pawn,
              isSelected: isSelected,
              onTap: isCurrentPlayer ? () => onPawnTap(pawn) : null,
            ),
          );
        }),
        if (pawns.isEmpty)
          const Text(
            '-',
            style: TextStyle(color: Colors.grey),
          ),
      ],
    );
  }
}
