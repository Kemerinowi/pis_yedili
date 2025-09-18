enum Suit { clubs, diamonds, hearts, spades }

enum Rank { ace, r2, r3, r4, r5, r6, r7, r8, r9, r10, jack, queen, king }

enum CardType { standard, jollyJoker }

class CardModel {
  final CardType type;
  final Suit? suit;
  final Rank? rank;

  const CardModel._(this.type, this.suit, this.rank);
  const CardModel.jolly() : this._(CardType.jollyJoker, null, null);
  const CardModel.standard(this.suit, this.rank) : type = CardType.standard;

  bool get isJack => type == CardType.standard && rank == Rank.jack;
  bool get isSeven => type == CardType.standard && rank == Rank.r7;
  bool get isEight => type == CardType.standard && rank == Rank.r8;
  bool get isTen => type == CardType.standard && rank == Rank.r10;
  bool get isAce => type == CardType.standard && rank == Rank.ace;

  /// UI etiketinde kullanılır; asla throw etmez.
  String display() {
    if (type == CardType.jollyJoker) return 'JJ';
    if (suit == null || rank == null) return '?';

    final r = switch (rank!) {
      Rank.ace => 'A',
      Rank.r2 => '2',
      Rank.r3 => '3',
      Rank.r4 => '4',
      Rank.r5 => '5',
      Rank.r6 => '6',
      Rank.r7 => '7',
      Rank.r8 => '8',
      Rank.r9 => '9',
      Rank.r10 => '10',
      Rank.jack => 'J',
      Rank.queen => 'Q',
      Rank.king => 'K',
    };
    final s = switch (suit!) {
      Suit.clubs => '♣',
      Suit.diamonds => '♦',
      Suit.hearts => '♥',
      Suit.spades => '♠',
    };
    return '$r$s';
  }
}
