import 'pawn.dart';
import 'player.dart';

class Cell {
  final List<Pawn> stack;

  Cell() : stack = [];

  Cell.fromStack(List<Pawn> pawns) : stack = List.from(pawns);

  Pawn? get topPawn => stack.isEmpty ? null : stack.last;

  Player? get owner => topPawn?.owner;

  bool get isEmpty => stack.isEmpty;

  bool canPlacePawn(Pawn pawn) {
    if (isEmpty) return true;
    return pawn.canCover(topPawn);
  }

  void placePawn(Pawn pawn) {
    if (!canPlacePawn(pawn)) {
      throw Exception('Cannot place pawn: ${pawn} on top of ${topPawn}');
    }
    stack.add(pawn);
  }

  Pawn? removePawn() {
    if (isEmpty) return null;
    return stack.removeLast();
  }

  Cell copy() {
    return Cell.fromStack(stack);
  }

  @override
  String toString() {
    if (isEmpty) return 'Empty';
    return 'Stack: ${stack.map((p) => p.size.displayName[0]).join('>')}';
  }
}
