import 'card.dart';
import '../game/game_state.dart';

class RulesEngine {
  static bool isPlayable({required GameState state, required CardModel card}) {
    final top = state.discardPile.isNotEmpty ? state.discardPile.last : null;

    // ── 0) İLK TUR: Herkes en az 1 kez ♣ atana kadar SADECE ♣ oynanabilir ──
    // (J/JJ dâhil efektli kartlar da oynanamaz; oyuncu isterse çekebilir.)
    if (state.firstClubPhase) {
      return (card.type == CardType.standard && card.suit == Suit.clubs);
    }

    // ── 1) Ceza savunması (7 ↔ JJ birbirine karışmaz) ──
    if (state.pendingPenalty > 0) {
      if (state.penaltyKind == PenaltyKind.seven) {
        return card.isSeven;
      } else if (state.penaltyKind == PenaltyKind.jolly) {
        return card.type == CardType.jollyJoker;
      }
    }

    // ── 2) As zinciri ──
    if (state.aceChainActive) {
      if (card.isAce) return true;
      if (card.type == CardType.standard && card.suit == state.aceChainSuit) {
        return !card.isAce;
      }
      return false;
    }

    // ── 3) J ve JJ her zaman atılabilir (ilk tur dışında) ──
    if (card.isJack) return true;
    if (card.type == CardType.jollyJoker) return true;

    // ── 4) Tür seçilmişse öncelikle o türe izin ver ──
    if (state.selectedSuit != null) {
      if (card.type == CardType.standard && card.suit == state.selectedSuit) {
        return true;
      }
      if (top != null &&
          top.type == CardType.standard &&
          card.type == CardType.standard &&
          card.rank == (top as CardModel).rank) {
        return true;
      }
      return false;
    }

    // ── 5) Normal eşleşme ──
    if (top == null) return true;
    if (top.type == CardType.jollyJoker) return true;
    if (card.type == CardType.standard && top.type == CardType.standard) {
      return card.suit == top.suit || card.rank == top.rank;
    }
    return true;
  }

  static void applyEffects({
    required GameState state,
    required CardModel card,
    required bool firstClubPhase,
    required Suit? Function()? onAskSuitForJack,
  }) {
    // İlk turda efekt yok (tamamen pasif)
    if (firstClubPhase) {
      return;
    }

    // As zinciri
    if (card.isAce) {
      state.aceChainActive = true;
      state.aceChainSuit = card.suit!;
      return;
    }
    if (state.aceChainActive &&
        card.type == CardType.standard &&
        card.suit == state.aceChainSuit &&
        !card.isAce) {
      state.aceChainActive = false;
      state.aceChainSuit = null;
    }

    // 7 / JJ ceza
    if (card.isSeven) {
      state.pendingPenalty += 3;
      state.penaltyKind = PenaltyKind.seven;
      return;
    }
    if (card.type == CardType.jollyJoker) {
      state.pendingPenalty += 10;
      state.penaltyKind = PenaltyKind.jolly;
      return;
    }

    // 8 / 10 (skip/bounce) — sıra ilerlemesi controller’da
    if (card.isEight || card.isTen) return;

    // J (wild): tür seçimi
    if (card.isJack) {
      final chosen = onAskSuitForJack?.call();
      if (chosen != null) state.selectedSuit = chosen;
      return;
    }

    // Seçilen suit temizleme (normal oyun)
    if (state.selectedSuit != null &&
        card.type == CardType.standard &&
        card.suit == state.selectedSuit) {
      state.selectedSuit = null;
    }
  }
}
