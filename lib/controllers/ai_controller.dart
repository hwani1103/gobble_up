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
        return _calculateMediumMove(board, waitingArea, aiPlayer);
      case AIDifficulty.hard:
        return _calculateHardMove(board, waitingArea, aiPlayer);
      case AIDifficulty.hell:
        return _calculateHellMove(board, waitingArea, aiPlayer);
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

  // MEDIUM AI: Look for winning moves, block opponent, avoid losses
  AIMove? _calculateMediumMove(
    Board board,
    Map<Player, List<Pawn>> waitingArea,
    Player aiPlayer,
  ) {
    final allMoves = _getAllPossibleMoves(board, waitingArea, aiPlayer);
    if (allMoves.isEmpty) return null;

    final opponent = aiPlayer.opponent;

    // 1. Check if AI can win in one move
    for (final move in allMoves) {
      if (_wouldWin(board, move, aiPlayer)) {
        return move;
      }
    }

    // 2. Block opponent's winning move
    final opponentMoves = _getAllPossibleMoves(board, waitingArea, opponent);
    for (final opponentMove in opponentMoves) {
      if (_wouldWin(board, opponentMove, opponent)) {
        // Try to block by placing at the same position
        final blockingMoves = allMoves.where(
          (move) => move.toPosition == opponentMove.toPosition,
        );
        if (blockingMoves.isNotEmpty) {
          return blockingMoves.first;
        }
      }
    }

    // 3. Avoid immediate loss
    final safeMoves = allMoves.where(
      (move) => !_wouldCauseImmediateLoss(board, move, aiPlayer),
    ).toList();

    final movesToChoose = safeMoves.isNotEmpty ? safeMoves : allMoves;

    // 4. Prefer center and strategic positions
    final centerMoves = movesToChoose.where(
      (move) => move.toPosition.row == 1 && move.toPosition.col == 1,
    ).toList();

    if (centerMoves.isNotEmpty) {
      return centerMoves[_random.nextInt(centerMoves.length)];
    }

    return movesToChoose[_random.nextInt(movesToChoose.length)];
  }

  // HARD AI: Minimax with depth 3
  AIMove? _calculateHardMove(
    Board board,
    Map<Player, List<Pawn>> waitingArea,
    Player aiPlayer,
  ) {
    final allMoves = _getAllPossibleMoves(board, waitingArea, aiPlayer);
    if (allMoves.isEmpty) return null;

    AIMove? bestMove;
    int bestScore = -10000;

    for (final move in allMoves) {
      final score = _minimax(
        board,
        waitingArea,
        move,
        depth: 3,
        isMaximizing: false,
        aiPlayer: aiPlayer,
        alpha: -10000,
        beta: 10000,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  // HELL AI: Deep Minimax with depth 5
  AIMove? _calculateHellMove(
    Board board,
    Map<Player, List<Pawn>> waitingArea,
    Player aiPlayer,
  ) {
    final allMoves = _getAllPossibleMoves(board, waitingArea, aiPlayer);
    if (allMoves.isEmpty) return null;

    AIMove? bestMove;
    int bestScore = -10000;

    for (final move in allMoves) {
      final score = _minimax(
        board,
        waitingArea,
        move,
        depth: 5,
        isMaximizing: false,
        aiPlayer: aiPlayer,
        alpha: -10000,
        beta: 10000,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  bool _wouldWin(Board board, AIMove move, Player player) {
    final tempBoard = board.copy();

    if (move.fromPosition != null) {
      tempBoard.removePawn(move.fromPosition!);
    }

    tempBoard.placePawn(move.toPosition, move.pawn);

    final winner = tempBoard.checkWinner();
    return winner == player;
  }

  int _minimax(
    Board board,
    Map<Player, List<Pawn>> waitingArea,
    AIMove move,
    {
    required int depth,
    required bool isMaximizing,
    required Player aiPlayer,
    required int alpha,
    required int beta,
  }) {
    // Apply move
    final newBoard = board.copy();
    // Deep copy the waiting area to avoid modifying the original
    final newWaitingArea = waitingArea.map(
      (key, value) => MapEntry(key, List<Pawn>.from(value)),
    );

    if (move.fromPosition != null) {
      newBoard.removePawn(move.fromPosition!);
    } else {
      newWaitingArea[move.pawn.owner]?.remove(move.pawn);
    }

    newBoard.placePawn(move.toPosition, move.pawn);

    // Check terminal state
    final winner = newBoard.checkWinner();
    if (winner != null) {
      return winner == aiPlayer ? 1000 : -1000;
    }

    if (depth == 0) {
      return _evaluateBoard(newBoard, aiPlayer);
    }

    final currentPlayer = isMaximizing ? aiPlayer : aiPlayer.opponent;
    final possibleMoves = _getAllPossibleMoves(
      newBoard,
      newWaitingArea,
      currentPlayer,
    );

    if (possibleMoves.isEmpty) {
      return _evaluateBoard(newBoard, aiPlayer);
    }

    if (isMaximizing) {
      int maxScore = -10000;
      for (final nextMove in possibleMoves) {
        final score = _minimax(
          newBoard,
          newWaitingArea,
          nextMove,
          depth: depth - 1,
          isMaximizing: false,
          aiPlayer: aiPlayer,
          alpha: alpha,
          beta: beta,
        );
        maxScore = score > maxScore ? score : maxScore;
        alpha = alpha > score ? alpha : score;
        if (beta <= alpha) break; // Beta cutoff
      }
      return maxScore;
    } else {
      int minScore = 10000;
      for (final nextMove in possibleMoves) {
        final score = _minimax(
          newBoard,
          newWaitingArea,
          nextMove,
          depth: depth - 1,
          isMaximizing: true,
          aiPlayer: aiPlayer,
          alpha: alpha,
          beta: beta,
        );
        minScore = score < minScore ? score : minScore;
        beta = beta < score ? beta : score;
        if (beta <= alpha) break; // Alpha cutoff
      }
      return minScore;
    }
  }

  int _evaluateBoard(Board board, Player aiPlayer) {
    int score = 0;
    final opponent = aiPlayer.opponent;

    // 1. Evaluate lines (rows, columns, diagonals) with piece size consideration
    final lines = [
      // Rows
      [Position(0, 0), Position(0, 1), Position(0, 2)],
      [Position(1, 0), Position(1, 1), Position(1, 2)],
      [Position(2, 0), Position(2, 1), Position(2, 2)],
      // Columns
      [Position(0, 0), Position(1, 0), Position(2, 0)],
      [Position(0, 1), Position(1, 1), Position(2, 1)],
      [Position(0, 2), Position(1, 2), Position(2, 2)],
      // Diagonals
      [Position(0, 0), Position(1, 1), Position(2, 2)],
      [Position(0, 2), Position(1, 1), Position(2, 0)],
    ];

    for (final line in lines) {
      int aiCount = 0;
      int opponentCount = 0;
      int aiLargeCount = 0; // Large pieces can't be covered
      int opponentLargeCount = 0;

      for (final pos in line) {
        final cell = board.getCell(pos);
        final pawn = cell.topPawn;
        if (pawn != null) {
          if (pawn.owner == aiPlayer) {
            aiCount++;
            if (pawn.size == PawnSize.large) aiLargeCount++;
          } else {
            opponentCount++;
            if (pawn.size == PawnSize.large) opponentLargeCount++;
          }
        }
      }

      // Score based on potential lines with size bonus
      if (aiCount > 0 && opponentCount == 0) {
        score += aiCount * aiCount * 15 + aiLargeCount * 20;
      } else if (opponentCount > 0 && aiCount == 0) {
        score -= opponentCount * opponentCount * 15 + opponentLargeCount * 20;
      }
    }

    // 2. Bonus for center control with size consideration
    final center = board.getCell(Position(1, 1)).topPawn;
    if (center?.owner == aiPlayer) {
      score += 40 + (center!.size == PawnSize.large ? 30 :
                     center.size == PawnSize.medium ? 15 : 0);
    } else if (center?.owner == opponent) {
      score -= 40 + (center!.size == PawnSize.large ? 30 :
                     center.size == PawnSize.medium ? 15 : 0);
    }

    // 3. Corner control bonus
    final corners = [Position(0, 0), Position(0, 2), Position(2, 0), Position(2, 2)];
    for (final pos in corners) {
      final pawn = board.getCell(pos).topPawn;
      if (pawn?.owner == aiPlayer) {
        score += 15 + (pawn!.size == PawnSize.large ? 15 : 0);
      } else if (pawn?.owner == opponent) {
        score -= 15 + (pawn!.size == PawnSize.large ? 15 : 0);
      }
    }

    // 4. Piece vulnerability (small pieces are vulnerable)
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final cell = board.getCell(Position(row, col));
        final pawn = cell.topPawn;
        if (pawn != null) {
          if (pawn.owner == aiPlayer) {
            // Penalize vulnerable pieces
            if (pawn.size == PawnSize.small) score -= 5;
            // Reward protected Large pieces
            if (pawn.size == PawnSize.large) score += 25;
          } else {
            // Opponent's vulnerable pieces are good for us
            if (pawn.size == PawnSize.small) score += 5;
            // Opponent's Large pieces are bad for us
            if (pawn.size == PawnSize.large) score -= 25;
          }
        }
      }
    }

    return score;
  }
}
