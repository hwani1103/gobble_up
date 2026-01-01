import 'package:flutter/material.dart';
import '../models/pawn.dart';
import 'half_cylinder_pawn.dart';

class PawnWidget extends StatelessWidget {
  final Pawn pawn;
  final bool isSelected;
  final VoidCallback? onTap;

  const PawnWidget({
    super.key,
    required this.pawn,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: HalfCylinderPawn(
        color: pawn.owner.color,
        size: pawn.size.displaySize,
        isSelected: isSelected,
      ),
    );
  }
}
