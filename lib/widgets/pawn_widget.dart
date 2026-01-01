import 'package:flutter/material.dart';
import '../models/pawn.dart';

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
      child: Container(
        width: pawn.size.displaySize,
        height: pawn.size.displaySize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pawn.owner.color,
          border: isSelected
              ? Border.all(color: Colors.yellow, width: 4)
              : Border.all(color: Colors.black26, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            pawn.size.displayName[0],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: pawn.size.displaySize * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
