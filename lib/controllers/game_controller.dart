import 'package:flutter/foundation.dart';
import '../models/board.dart';
import '../models/game_state.dart';
import '../models/pawn.dart';
import '../models/player.dart';

class GameController extends ChangeNotifier {
  GameState _state;

  GameController() : _state = GameState.initial();

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
    if (_state.phase != GamePhase.selectingPawn) return;

    final cell = board.getCell(position);
    final pawn = cell.topPawn;

    if (pawn == null || pawn.owner != currentPlayer) return;

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
      // Invalid move, deselect
      cancelSelection();
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
    _state = GameState.initial();
    notifyListeners();
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
