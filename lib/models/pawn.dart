import 'player.dart';

enum PawnSize {
  small,
  medium,
  large;

  bool canCoverSize(PawnSize? other) {
    if (other == null) return true;
    return index > other.index;
  }

  double get displaySize {
    switch (this) {
      case PawnSize.small:
        return 35.0;
      case PawnSize.medium:
        return 50.0;
      case PawnSize.large:
        return 65.0;
    }
  }

  String get displayName {
    switch (this) {
      case PawnSize.small:
        return 'Small';
      case PawnSize.medium:
        return 'Medium';
      case PawnSize.large:
        return 'Large';
    }
  }
}

class Pawn {
  final Player owner;
  final PawnSize size;
  final String id;

  Pawn({
    required this.owner,
    required this.size,
    required this.id,
  });

  bool canCover(Pawn? other) {
    if (other == null) return true;
    return size.canCoverSize(other.size);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pawn &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '${owner.name} ${size.displayName}';
}
