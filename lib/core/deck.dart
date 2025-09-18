import 'dart:math';
import 'card.dart';
import '../game/game_settings.dart';

/// 2 deste (2×52 = 104). J = Normal Joker.
/// JJ (Jolly Joker) açık ise her desteye 2 adet eklenir (toplam 108).
List<CardModel> buildDeck(GameSettings settings) {
  final deck = <CardModel>[];

  const deckCount = 2; // hep 2 deste
  for (var d = 0; d < deckCount; d++) {
    // Standart 52 kart
    for (final s in Suit.values) {
      for (final r in Rank.values) {
        deck.add(CardModel.standard(s, r));
      }
    }
    // İsteğe bağlı JJ
    if (settings.useJollyJoker) {
      deck.add(const CardModel.jolly());
      deck.add(const CardModel.jolly());
    }
  }

  // Fisher–Yates shuffle (seed: değişken; hep aynı sırayı vermez)
  final rnd = Random(DateTime.now().microsecondsSinceEpoch ^ deck.length);
  for (int i = deck.length - 1; i > 0; i--) {
    final j = rnd.nextInt(i + 1);
    final tmp = deck[i];
    deck[i] = deck[j];
    deck[j] = tmp;
  }

  return deck;
}
