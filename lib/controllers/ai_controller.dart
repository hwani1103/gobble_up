import 'dart:math';
import '../models/board.dart';
import '../models/game_mode.dart';
import '../models/pawn.dart';
import '../models/player.dart';

class AIMove {
  final Pawn pawn;
  final Position? fromPosition;
  final Position toPosition;

  AIMove({
    required this.pawn,
    this.fromPosition,
    required this.toPosition,
  });
}

class AIController {
  final Random _random = Random();

  AIMove? calculateMove({
    required Board board,
    required Map<Player, List<Pawn>> waitingArea,
    required Player aiPlayer,
    required AIDifficulty difficulty,
  }) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return _calculateEasyMove(board, waitingArea, aiPlayer);
      case AIDifficulty.medium:
      case AIDifficulty.hard:
      case AIDifficulty.hell:
        // Not implemented yet
        return _calculateEasyMove(board, waitingArea, aiPlayer);
    }
  }

  AIMove? _calculateEasyMove(
    Board board,
    Map<Player, List<Pawn>> waitingArea,
    Player aiPlayer,
  ) {
    final allPossibleMoves = _getAllPossibleMoves(board, waitingArea, aiPlayer);

    if (allPossibleMoves.isEmpty) return null;

    // Filter out moves that would cause immediate loss
    final safeMoves = allPossibleMoves.where((move) {
      return !_wouldCauseImmediateLoss(board, move, aiPlayer);
    }).toList();

    // If all moves cause immediate loss, just pick a random one
    final movesToChooseFrom = safeMoves.isNotEmpty ? safeMoves : allPossibleMoves;

    // Pick a random move
    return movesToChooseFrom[_random.nextInt(movesToChooseFrom.length)];
  }

  List<AIMove> _getAllPossibleMoves(
    Board board,
    Map<Player, List<Pawn>> waitingArea,
    Player aiPlayer,
  ) {
    final moves = <AIMove>[];

    // Moves from waiting area
    final waitingPawns = waitingArea[aiPlayer] ?? [];
    for (final pawn in waitingPawns) {
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          final position = Position(row, col);
          if (board.canPlacePawn(position, pawn)) {
            moves.add(AIMove(
              pawn: pawn,
              fromPosition: null,
              toPosition: position,
            ));
          }
        }
      }
    }

    // Moves from board
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final fromPosition = Position(row, col);
        final cell = board.getCell(fromPosition);
        final pawn = cell.topPawn;

        if (pawn != null && pawn.owner == aiPlayer) {
          // Try moving this pawn to all other positions
          for (int toRow = 0; toRow < 3; toRow++) {
            for (int toCol = 0; toCol < 3; toCol++) {
              final toPosition = Position(toRow, toCol);

              // Skip same position
              if (fromPosition == toPosition) continue;

              // Temporarily remove pawn and check if move is valid
              final tempBoard = board.copy();
              tempBoard.removePawn(fromPosition);

              if (tempBoard.canPlacePawn(toPosition, pawn)) {
                moves.add(AIMove(
                  pawn: pawn,
                  fromPosition: fromPosition,
                  toPosition: toPosition,
                ));
              }
            }
          }
        }
      }
    }

    return moves;
  }

  bool _wouldCauseImmediateLoss(Board board, AIMove move, Player aiPlayer) {
    final tempBoard = board.copy();

    // If moving from board, remove pawn first
    if (move.fromPosition != null) {
      tempBoard.removePawn(move.fromPosition!);
    }

    // Place pawn at destination
    tempBoard.placePawn(move.toPosition, move.pawn);

    // Check if opponent won
    final winner = tempBoard.checkWinner();
    return winner != null && winner != aiPlayer;
  }
}
