enum GameMode {
  humanVsHuman,
  humanVsAI;
}

enum AIDifficulty {
  easy('초급'),
  medium('중급'),
  hard('상급'),
  hell('지옥');

  final String displayName;
  const AIDifficulty(this.displayName);
}
