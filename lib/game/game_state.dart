import 'package:flutter/foundation.dart';
import '../core/card.dart';

/// ARTIK public (dosyalar arası erişilebilir)
enum PenaltyKind { none, seven, jolly }

class Player {
  final String id;
  final String name;
  final bool isHuman;
  final List<CardModel> hand;

  Player({
    required this.id,
    required this.name,
    required this.isHuman,
    List<CardModel>? initial,
  }) : hand = initial ?? [];
}

class GameState extends ChangeNotifier {
  final List<Player> players;
  final List<CardModel> drawPile;
  final List<CardModel> discardPile;

  int turnIndex = 0;

  // İlk tur SİNEK kuralı
  final Set<String> _playedClubOnce = {};
  bool get firstClubPhase => _playedClubOnce.length < players.length;

  // J (wild) sonrası seçilen tür
  Suit? selectedSuit;

  // As zinciri
  bool aceChainActive = false;
  Suit? aceChainSuit;

  // Cezalar
  int pendingPenalty = 0;
  PenaltyKind penaltyKind = PenaltyKind.none;

  GameState({
    required this.players,
    required this.drawPile,
    required this.discardPile,
  });

  Player get current => players[turnIndex];

  void nextTurn({int step = 1}) {
    turnIndex = (turnIndex + step) % players.length;
  }

  void prevTurnOneStep() {
    turnIndex = (turnIndex - 1) % players.length;
    if (turnIndex < 0) turnIndex += players.length;
  }

  void markPlayedClubIfNeeded(Player p, CardModel c) {
    if (c.type == CardType.standard && c.suit == Suit.clubs) {
      _playedClubOnce.add(p.id);
    }
  }

  void pushDiscard(CardModel c) {
    discardPile.add(c);
  }

  CardModel drawOne() {
    if (drawPile.isEmpty) {
      // karıştır: son kart yerde kalsın
      final top = discardPile.removeLast();
      drawPile.addAll(discardPile);
      discardPile
        ..clear()
        ..add(top);
    }
    return drawPile.removeLast();
  }

  void notify() => notifyListeners();
}
