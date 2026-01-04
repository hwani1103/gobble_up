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
    }
  }

  // EASY AI: Minimax with depth 2
  AIMove? _calculateEasyMove(
    Board board,
    Map<Player, List<Pawn>> waitingArea,
    Player aiPlayer,
  ) {
    final allMoves = _getAllPossibleMoves(board, waitingArea, aiPlayer);
    if (allMoves.isEmpty) return null;

    // ALWAYS take immediate winning move if available
    for (final move in allMoves) {
      if (_wouldWin(board, move, aiPlayer)) {
        return move;
      }
    }

    AIMove? bestMove;
    int bestScore = -10000;

    for (final move in allMoves) {
      final score = _minimax(
        board,
        waitingArea,
        move,
        depth: 2,
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

  // MEDIUM AI: Minimax with depth 3
  AIMove? _calculateMediumMove(
    Board board,
    Map<Player, List<Pawn>> waitingArea,
    Player aiPlayer,
  ) {
    final allMoves = _getAllPossibleMoves(board, waitingArea, aiPlayer);
    if (allMoves.isEmpty) return null;

    // ALWAYS take immediate winning move if available
    for (final move in allMoves) {
      if (_wouldWin(board, move, aiPlayer)) {
        return move;
      }
    }

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

  // HARD AI: Deep Minimax with depth 4
  AIMove? _calculateHardMove(
    Board board,
    Map<Player, List<Pawn>> waitingArea,
    Player aiPlayer,
  ) {
    final allMoves = _getAllPossibleMoves(board, waitingArea, aiPlayer);
    if (allMoves.isEmpty) return null;

    // Opening move: Just play center or corner quickly (no need for deep thinking)
    if (_isOpeningMove(board)) {
      return _getSimpleOpeningMove(waitingArea, aiPlayer);
    }

    // ALWAYS take immediate winning move if available
    for (final move in allMoves) {
      if (_wouldWin(board, move, aiPlayer)) {
        return move;
      }
    }

    final moveScores = <AIMove, int>{};

    for (final move in allMoves) {
      final score = _minimax(
        board,
        waitingArea,
        move,
        depth: 4,
        isMaximizing: false,
        aiPlayer: aiPlayer,
        alpha: -10000,
        beta: 10000,
      );
      moveScores[move] = score;
    }

    // Find the best score
    final bestScore = moveScores.values.reduce((a, b) => a > b ? a : b);

    // Collect all moves with the best score (or within small margin for variety)
    final threshold = 10; // Allow moves within 10 points of best
    final goodMoves = moveScores.entries
        .where((entry) => entry.value >= bestScore - threshold)
        .map((entry) => entry.key)
        .toList();

    // Randomly pick from good moves for variety in AI vs AI
    return goodMoves[_random.nextInt(goodMoves.length)];
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

  // Check if this is the opening move (board is empty or has only 1 piece)
  bool _isOpeningMove(Board board) {
    int pieceCount = 0;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (!board.getCell(Position(row, col)).isEmpty) {
          pieceCount++;
        }
      }
    }
    return pieceCount == 0;
  }

  // Simple opening move: play center or a random corner with random pawn
  AIMove? _getSimpleOpeningMove(
    Map<Player, List<Pawn>> waitingArea,
    Player aiPlayer,
  ) {
    final waitingPawns = waitingArea[aiPlayer] ?? [];
    if (waitingPawns.isEmpty) return null;

    // Randomly choose between center and corners
    final positions = [
      Position(1, 1), // Center
      Position(0, 0), // Top-left
      Position(0, 2), // Top-right
      Position(2, 0), // Bottom-left
      Position(2, 2), // Bottom-right
    ];
    positions.shuffle(_random);

    // Pick a random pawn
    final selectedPawn = waitingPawns[_random.nextInt(waitingPawns.length)];

    return AIMove(
      pawn: selectedPawn,
      fromPosition: null,
      toPosition: positions.first, // Random position from shuffled list
    );
  }
}
