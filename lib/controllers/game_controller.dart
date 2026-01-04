import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/board.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../models/pawn.dart';
import '../models/player.dart';
import 'ai_controller.dart';

class GameController extends ChangeNotifier {
  GameState _state;
  final GameMode gameMode;
  final AIDifficulty? aiDifficulty;
  final AIController _aiController = AIController();
  final Random _random = Random();
  Timer? _aiMoveTimer;

  GameController({
    this.gameMode = GameMode.humanVsHuman,
    this.aiDifficulty,
  }) : _state = GameState.initial(
          initialPlayer: (gameMode == GameMode.humanVsAI &&
                  aiDifficulty == AIDifficulty.hell)
              ? Player.player2
              : Player.player1,
        ) {
    // Trigger AI move if AI starts first
    if (isAITurn) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkAndTriggerAIMove();
      });
    }
  }

  GameState get state => _state;

  Board get board => _state.board;
  Player get currentPlayer => _state.currentPlayer;
  GamePhase get phase => _state.phase;
  Pawn? get selectedPawn => _state.selectedPawn;
  Position? get selectedPosition => _state.selectedPosition;
  Player? get winner => _state.winner;

  List<Pawn> getCurrentPlayerWaitingPawns() {
    return _state.getCurrentPlayerWaitingPawns();
  }

  void selectPawnFromWaiting(Pawn pawn) {
    if (_state.isGameOver) return;
    if (pawn.owner != currentPlayer) return;

    // Toggle: if already selected, deselect it
    if (_state.selectedPawn == pawn) {
      cancelSelection();
      return;
    }

    if (_state.phase != GamePhase.selectingPawn) return;

    _state = _state.copyWith(
      selectedPawn: pawn,
      selectedPosition: null,
      phase: GamePhase.selectingDestination,
    );
    notifyListeners();
  }

  void selectPawnFromBoard(Position position) {
    if (_state.isGameOver) return;

    final cell = board.getCell(position);
    final pawn = cell.topPawn;

    if (pawn == null || pawn.owner != currentPlayer) return;

    // Toggle: if already selected at this position, deselect it
    if (_state.selectedPawn == pawn && _state.selectedPosition == position) {
      cancelSelection();
      return;
    }

    if (_state.phase != GamePhase.selectingPawn) return;

    _state = _state.copyWith(
      selectedPawn: pawn,
      selectedPosition: position,
      phase: GamePhase.selectingDestination,
    );
    notifyListeners();
  }

  void selectDestination(Position destination) {
    if (_state.isGameOver) return;
    if (_state.phase != GamePhase.selectingDestination) return;
    if (_state.selectedPawn == null) return;

    final pawn = _state.selectedPawn!;

    // Check if the move is valid (uses the corrected canPlacePawn logic)
    if (!canPlacePawn(destination)) {
      // Invalid move, just ignore
      return;
    }

    // Make a copy of the board and waiting area for modification
    final newBoard = board.copy();
    final newWaitingArea = Map<Player, List<Pawn>>.from(_state.waitingArea);

    // If pawn is from board, remove it from original position
    if (_state.selectedPosition != null) {
      newBoard.removePawn(_state.selectedPosition!);
    } else {
      // If pawn is from waiting area, remove it from there
      newWaitingArea[currentPlayer]?.remove(pawn);
    }

    // Place the pawn at destination
    newBoard.placePawn(destination, pawn);

    // Play haptic feedback (light impact)
    HapticFeedback.lightImpact();

    // Check for winner
    final winner = newBoard.checkWinner();

    if (winner != null) {
      // Game over
      _state = _state.copyWith(
        board: newBoard,
        waitingArea: newWaitingArea,
        phase: GamePhase.gameOver,
        winner: winner,
        clearSelection: true,
      );
    } else {
      // Switch turns
      _state = _state.copyWith(
        board: newBoard,
        waitingArea: newWaitingArea,
        currentPlayer: currentPlayer.opponent,
        phase: GamePhase.selectingPawn,
        clearSelection: true,
      );
    }

    notifyListeners();

    // Check if it's AI's turn after the move
    _checkAndTriggerAIMove();
  }

  void cancelSelection() {
    if (_state.isGameOver) return;

    _state = _state.copyWith(
      phase: GamePhase.selectingPawn,
      clearSelection: true,
    );
    notifyListeners();
  }

  void resetGame() {
    _aiMoveTimer?.cancel();
    _state = GameState.initial(
      initialPlayer: (gameMode == GameMode.humanVsAI &&
              aiDifficulty == AIDifficulty.hell)
          ? Player.player2
          : Player.player1,
    );
    notifyListeners();

    // Trigger AI move if AI starts first
    if (isAITurn) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkAndTriggerAIMove();
      });
    }
  }

  @override
  void dispose() {
    _aiMoveTimer?.cancel();
    super.dispose();
  }

  bool get isAITurn {
    return gameMode == GameMode.humanVsAI &&
        currentPlayer == Player.player2 &&
        !_state.isGameOver;
  }

  void _checkAndTriggerAIMove() {
    if (isAITurn) {
      // Random delay between 2-4 seconds
      final delaySeconds = 2 + _random.nextInt(3);
      _aiMoveTimer?.cancel();
      _aiMoveTimer = Timer(Duration(seconds: delaySeconds), () {
        _makeAIMove();
      });
    }
  }

  void _makeAIMove() {
    if (!isAITurn || aiDifficulty == null) return;

    final aiMove = _aiController.calculateMove(
      board: board,
      waitingArea: _state.waitingArea,
      aiPlayer: Player.player2,
      difficulty: aiDifficulty!,
    );

    if (aiMove == null) return;

    // Select the pawn
    _state = _state.copyWith(
      selectedPawn: aiMove.pawn,
      selectedPosition: aiMove.fromPosition,
      phase: GamePhase.selectingDestination,
    );
    notifyListeners();

    // Small delay before placing (for visual feedback)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_state.isGameOver) return;

      // Place the pawn
      selectDestination(aiMove.toPosition);
    });
  }

  bool canPlacePawn(Position position) {
    if (_state.selectedPawn == null) return false;

    final pawn = _state.selectedPawn!;
    final selectedPos = _state.selectedPosition;

    // Cannot move to the same position
    if (selectedPos != null && selectedPos == position) {
      return false;
    }

    // If pawn is from board, check with the pawn temporarily removed
    if (selectedPos != null) {
      final tempBoard = board.copy();
      tempBoard.removePawn(selectedPos);
      return tempBoard.canPlacePawn(position, pawn);
    }

    // If pawn is from waiting area, check as is
    return board.canPlacePawn(position, pawn);
  }
}
