import 'dart:math';
import '../core/card.dart';
import '../core/rules_engine.dart';
import '../game/game_state.dart';
import '../game/game_settings.dart';

/// Bot’un tek hamlesi: play/draw/pass
class BotDecision {
  final CardModel? playCard;
  final Suit? jackChosenSuit; // J oynayacaksa seçeceği tür
  final bool draw;
  final bool pass;

  const BotDecision._({
    required this.playCard,
    required this.jackChosenSuit,
    required this.draw,
    required this.pass,
  });

  factory BotDecision.play(CardModel c, {Suit? jackSuit}) => BotDecision._(
    playCard: c,
    jackChosenSuit: jackSuit,
    draw: false,
    pass: false,
  );

  factory BotDecision.draw() => const BotDecision._(
    playCard: null,
    jackChosenSuit: null,
    draw: true,
    pass: false,
  );

  factory BotDecision.pass() => const BotDecision._(
    playCard: null,
    jackChosenSuit: null,
    draw: false,
    pass: true,
  );
}

class BotStrategy {
  static final _rnd = Random();

  static BotDecision decide({
    required GameSettings settings,
    required GameState gs,
    required Player bot,
  }) {
    // 1) Ceza varken: sadece uygun kartla savun (7↔JJ karışmaz).
    if (gs.pendingPenalty > 0) {
      final defend = _defenseCard(gs, bot);
      if (defend != null) {
        return BotDecision.play(defend);
      }
      // savunamaz → çekecek (GameController toplamı çektirecek)
      return BotDecision.draw();
    }

    // 2) Oynanabilir kartları topla
    final playable = bot.hand
        .where((c) => RulesEngine.isPlayable(state: gs, card: c))
        .toList();
    if (playable.isEmpty) {
      // Oynayacak yok → çek
      return BotDecision.draw();
    }

    switch (settings.difficulty) {
      case Difficulty.easy:
        return _easy(gs, bot, playable);
      case Difficulty.normal:
        return _normal(gs, bot, playable);
      case Difficulty.hard:
        return _hard(gs, bot, playable);
    }
  }

  // ---------------- helpers ----------------

  // ... (dosyanın başı aynı)
  static CardModel? _defenseCard(GameState gs, Player bot) {
    if (gs.penaltyKind == PenaltyKind.seven) {
      for (final c in bot.hand) {
        if (c.isSeven) return c;
      }
      return null;
    } else if (gs.penaltyKind == PenaltyKind.jolly) {
      for (final c in bot.hand) {
        if (c.type == CardType.jollyJoker) return c;
      }
      return null;
    }
    return null;
  }
  // ... (geri kalan dosya aynı)

  static Map<Suit, int> _suitCounts(Iterable<CardModel> cards) {
    final m = {for (final s in Suit.values) s: 0};
    for (final c in cards) {
      if (c.type == CardType.standard && c.suit != null) {
        m[c.suit!] = (m[c.suit!] ?? 0) + 1;
      }
    }
    return m;
  }

  static Suit _bestSuit(Iterable<CardModel> hand) {
    final counts = _suitCounts(hand);
    Suit best = Suit.clubs;
    int max = -1;
    counts.forEach((s, n) {
      if (n > max) {
        max = n;
        best = s;
      }
    });
    return best;
  }

  static int _nextIndex(GameState gs) => (gs.turnIndex + 1) % gs.players.length;
  static int _prevIndex(GameState gs) =>
      (gs.turnIndex - 1 + gs.players.length) % gs.players.length;

  // ---------------- levels ----------------

  static BotDecision _easy(GameState gs, Player bot, List<CardModel> playable) {
    // J oynarsa rastgele tür
    final c = playable.first;
    if (c.isJack && !gs.firstClubPhase) {
      return BotDecision.play(c, jackSuit: Suit.values[_rnd.nextInt(4)]);
    }
    return BotDecision.play(c);
  }

  static BotDecision _normal(
    GameState gs,
    Player bot,
    List<CardModel> playable,
  ) {
    // Basit heuristikler:
    // - J: çoğunluk türüne çevir.
    // - 8: sonraki oyuncunun eli azsa (<=2) tercih et.
    // - 10: önceki oyuncu azsa (<=2) tercih et.
    // - JJ/7: sonraki oyuncu azsa daha istekli kullan.
    final nextCount = gs.players[_nextIndex(gs)].hand.length;
    final prevCount = gs.players[_prevIndex(gs)].hand.length;

    // 8/10 fırsatı
    final eight = playable
        .where((c) => c.isEight && !gs.firstClubPhase)
        .toList();
    if (eight.isNotEmpty && nextCount <= 2) {
      return BotDecision.play(eight.first);
    }
    final ten = playable.where((c) => c.isTen && !gs.firstClubPhase).toList();
    if (ten.isNotEmpty && prevCount <= 2) {
      return BotDecision.play(ten.first);
    }

    // JJ/7 fırsatı
    final jj = playable
        .where((c) => c.type == CardType.jollyJoker && !gs.firstClubPhase)
        .toList();
    if (jj.isNotEmpty && nextCount <= 3) {
      return BotDecision.play(jj.first);
    }
    final seven = playable
        .where((c) => c.isSeven && !gs.firstClubPhase)
        .toList();
    if (seven.isNotEmpty && nextCount <= 2) {
      return BotDecision.play(seven.first);
    }

    // J: çoğunluk türe çevir
    final j = playable.where((c) => c.isJack).toList();
    if (j.isNotEmpty && !gs.firstClubPhase) {
      return BotDecision.play(j.first, jackSuit: _bestSuit(bot.hand));
    }

    // Aksi halde suit çoğunluğunu koruyan sıradan bir kart at
    playable.sort((a, b) {
      // çoğunluk suitine ait kartlar öne
      final best = _bestSuit(bot.hand);
      final aBest = (a.type == CardType.standard && a.suit == best) ? 0 : 1;
      final bBest = (b.type == CardType.standard && b.suit == best) ? 0 : 1;
      return aBest.compareTo(bBest);
    });
    return BotDecision.play(playable.first);
  }

  static BotDecision _hard(GameState gs, Player bot, List<CardModel> playable) {
    // Skor tabanlı seçim
    final next = gs.players[_nextIndex(gs)];
    final prev = gs.players[_prevIndex(gs)];
    final bestSuit = _bestSuit(bot.hand);

    CardModel? bestCard;
    Suit? jackSuit;
    double bestScore = -1e9;

    for (final c in playable) {
      double s = 0;

      // İlk turda efektler kapalı: etkili kartların puanını kıs
      final effectsOff = gs.firstClubPhase;

      // el azaltma (az kartla bitirmeye yaklaşmak)
      s += 2.0;

      // suit çoğunluğu koru
      if (c.type == CardType.standard && c.suit == bestSuit) s += 2.5;

      // J: tür değiştirme avantajı
      if (c.isJack) {
        if (!effectsOff) {
          final suit = bestSuit;
          jackSuit = suit;
          s += 6.0 + _suitCounts(bot.hand)[suit]!.toDouble();
        } else {
          s -= 2.0; // ilk tur: etkisiz
        }
      }

      // 8: sonraki azsa çok değerli
      if (c.isEight && !effectsOff) {
        if (next.hand.length <= 2)
          s += 12.0;
        else
          s += 4.0;
      }

      // 10: önceki azsa değerli (tek adım geri)
      if (c.isTen && !effectsOff) {
        if (prev.hand.length <= 2)
          s += 10.0;
        else
          s += 3.0;
      }

      // 7 / JJ: cezayı “kritik” rakibe it
      if (c.isSeven && !effectsOff) {
        s += (next.hand.length <= 3) ? 11.0 : 5.0;
      }
      if (c.type == CardType.jollyJoker && !effectsOff) {
        s += (next.hand.length <= 4) ? 13.0 : 6.0;
      }

      // As zinciri: elde birden fazla As varsa zincir başlatmaya daha istekli
      if (c.isAce && !effectsOff) {
        final aces = bot.hand.where((x) => x.isAce).length;
        s += (aces >= 2) ? 8.0 : 1.0;
      }

      // Kırmızı/siyah dağılımına küçük denge (çeşitlilik)
      if (c.type == CardType.standard) {
        final red = (c.suit == Suit.hearts || c.suit == Suit.diamonds);
        s += red ? 0.2 : 0.1;
      }

      if (s > bestScore) {
        bestScore = s;
        bestCard = c;
        // J değilken jackSuit'i sıfırla
        if (!c.isJack) jackSuit = null;
      }
    }

    if (bestCard == null) {
      return BotDecision.draw();
    }
    return BotDecision.play(bestCard!, jackSuit: jackSuit);
  }
}
