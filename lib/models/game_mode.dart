enum GameMode {
  humanVsHuman,
  humanVsAI,
  aiVsAI;
}

enum AIDifficulty {
  easy('초급'),
  medium('중급'),
  hard('상급');

  final String displayName;
  const AIDifficulty(this.displayName);
}
