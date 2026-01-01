import 'cell.dart';
import 'pawn.dart';
import 'player.dart';

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  bool get isValid => row >= 0 && row < 3 && col >= 0 && col < 3;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';
}

class Board {
  final List<List<Cell>> cells;

  Board()
      : cells = List.generate(
          3,
          (_) => List.generate(3, (_) => Cell()),
        );

  Board.fromCells(List<List<Cell>> existingCells)
      : cells = existingCells.map((row) => row.map((cell) => cell.copy()).toList()).toList();

  Cell getCell(Position pos) {
    if (!pos.isValid) throw Exception('Invalid position: $pos');
    return cells[pos.row][pos.col];
  }

  bool canPlacePawn(Position pos, Pawn pawn) {
    if (!pos.isValid) return false;
    return getCell(pos).canPlacePawn(pawn);
  }

  void placePawn(Position pos, Pawn pawn) {
    if (!pos.isValid) throw Exception('Invalid position: $pos');
    getCell(pos).placePawn(pawn);
  }

  Pawn? removePawn(Position pos) {
    if (!pos.isValid) return null;
    return getCell(pos).removePawn();
  }

  Player? checkWinner() {
    // Check rows
    for (int row = 0; row < 3; row++) {
      final owner = cells[row][0].owner;
      if (owner != null &&
          cells[row][1].owner == owner &&
          cells[row][2].owner == owner) {
        return owner;
      }
    }

    // Check columns
    for (int col = 0; col < 3; col++) {
      final owner = cells[0][col].owner;
      if (owner != null &&
          cells[1][col].owner == owner &&
          cells[2][col].owner == owner) {
        return owner;
      }
    }

    // Check diagonals
    final center = cells[1][1].owner;
    if (center != null) {
      // Top-left to bottom-right
      if (cells[0][0].owner == center && cells[2][2].owner == center) {
        return center;
      }
      // Top-right to bottom-left
      if (cells[0][2].owner == center && cells[2][0].owner == center) {
        return center;
      }
    }

    return null;
  }

  List<Position>? getWinningLine() {
    // Check rows
    for (int row = 0; row < 3; row++) {
      final owner = cells[row][0].owner;
      if (owner != null &&
          cells[row][1].owner == owner &&
          cells[row][2].owner == owner) {
        return [Position(row, 0), Position(row, 1), Position(row, 2)];
      }
    }

    // Check columns
    for (int col = 0; col < 3; col++) {
      final owner = cells[0][col].owner;
      if (owner != null &&
          cells[1][col].owner == owner &&
          cells[2][col].owner == owner) {
        return [Position(0, col), Position(1, col), Position(2, col)];
      }
    }

    // Check diagonals
    final center = cells[1][1].owner;
    if (center != null) {
      // Top-left to bottom-right
      if (cells[0][0].owner == center && cells[2][2].owner == center) {
        return [Position(0, 0), Position(1, 1), Position(2, 2)];
      }
      // Top-right to bottom-left
      if (cells[0][2].owner == center && cells[2][0].owner == center) {
        return [Position(0, 2), Position(1, 1), Position(2, 0)];
      }
    }

    return null;
  }

  Board copy() {
    return Board.fromCells(cells);
  }
}
