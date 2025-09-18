enum Difficulty { easy, normal, hard }

class GameSettings {
  final bool useJollyJoker; // true => 108 kart (JJ aktif), false => 104
  final int players; // sabit 4
  final int shuffleSeed; // testler için deterministik karıştırma
  final Difficulty difficulty;

  const GameSettings({
    this.useJollyJoker = true,
    this.players = 4,
    this.shuffleSeed = 42,
    this.difficulty = Difficulty.normal,
  });
}
