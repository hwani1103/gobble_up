import 'board.dart';
import 'pawn.dart';
import 'player.dart';

enum GamePhase {
  selectingPawn,
  selectingDestination,
  gameOver,
}

class GameState {
  final Board board;
  final Player currentPlayer;
  final Map<Player, List<Pawn>> waitingArea;
  final GamePhase phase;
  final Pawn? selectedPawn;
  final Position? selectedPosition;
  final Player? winner;

  GameState({
    required this.board,
    required this.currentPlayer,
    required this.waitingArea,
    this.phase = GamePhase.selectingPawn,
    this.selectedPawn,
    this.selectedPosition,
    this.winner,
  });

  factory GameState.initial({Player initialPlayer = Player.player1}) {
    final waitingArea = <Player, List<Pawn>>{};

    // Initialize pawns for each player
    for (final player in Player.values) {
      waitingArea[player] = [
        // 2 large pawns
        Pawn(owner: player, size: PawnSize.large, id: '${player.name}-large-1'),
        Pawn(owner: player, size: PawnSize.large, id: '${player.name}-large-2'),
        // 2 medium pawns
        Pawn(owner: player, size: PawnSize.medium, id: '${player.name}-medium-1'),
        Pawn(owner: player, size: PawnSize.medium, id: '${player.name}-medium-2'),
        // 2 small pawns
        Pawn(owner: player, size: PawnSize.small, id: '${player.name}-small-1'),
        Pawn(owner: player, size: PawnSize.small, id: '${player.name}-small-2'),
      ];
    }

    return GameState(
      board: Board(),
      currentPlayer: initialPlayer,
      waitingArea: waitingArea,
    );
  }

  GameState copyWith({
    Board? board,
    Player? currentPlayer,
    Map<Player, List<Pawn>>? waitingArea,
    GamePhase? phase,
    Pawn? selectedPawn,
    Position? selectedPosition,
    Player? winner,
    bool clearSelection = false,
  }) {
    return GameState(
      board: board ?? this.board.copy(),
      currentPlayer: currentPlayer ?? this.currentPlayer,
      waitingArea: waitingArea ?? Map.from(this.waitingArea),
      phase: phase ?? this.phase,
      selectedPawn: clearSelection ? null : (selectedPawn ?? this.selectedPawn),
      selectedPosition: clearSelection ? null : (selectedPosition ?? this.selectedPosition),
      winner: winner ?? this.winner,
    );
  }

  bool get isGameOver => phase == GamePhase.gameOver;

  List<Pawn> getCurrentPlayerWaitingPawns() {
    return waitingArea[currentPlayer] ?? [];
  }
}
