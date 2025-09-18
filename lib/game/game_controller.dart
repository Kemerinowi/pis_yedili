import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/card.dart';
import '../core/deck.dart';
import '../core/rules_engine.dart';
import '../bots/strategy.dart';
import 'game_settings.dart';
import 'game_state.dart';

class GameController {
  final GameSettings settings;
  late final GameState state;

  bool _botRunning = false;

  GameController(this.settings) {
    _init();
  }

  void _init() {
    final deck = buildDeck(settings);
    final players = List.generate(4, (i) {
      return Player(
        id: 'p$i',
        name: switch (i) {
          0 => 'Sen',
          1 => 'Sol',
          2 => 'Karşı',
          _ => 'Sağ',
        },
        isHuman: i == 0,
      );
    });

    // dağıtım
    for (var r = 0; r < 7; r++) {
      for (var p = 0; p < players.length; p++) {
        players[p].hand.add(deck.removeLast());
      }
    }

    // ilk kartı aç
    final discard = <CardModel>[deck.removeLast()];
    state = GameState(players: players, drawPile: deck, discardPile: discard);
    state.turnIndex = 0;

    _maybeBotTurn(); // oyunu başlatınca bot olabilir
  }

  GameState get gs => state;

  /// İnsan için çoklu atma: SADECE "As zinciri" sırasında geçerli.
  /// - As atarsan: sıra sende kalır (başka As daha atabilirsin).
  /// - Zinciri, son As’ın türünden As-olmayan bir kartla kırarsan: turun otomatik biter.
  /// - 7/JJ/8/10 ve ilk turda (SİNEK fazı) her zaman sıra ilerler (çoklu atış yok).
  bool playCard(
    CardModel card, {
    Suit? jackChosen,
    bool keepTurn = false, // UI'dan gönderilse bile kuralla sınırlıyoruz.
  }) {
    final p = gs.current;

    if (!p.hand.contains(card)) return false;
    if (!RulesEngine.isPlayable(state: gs, card: card)) return false;

    // As zinciri durumu efektlerden ÖNCE gerekiyor (karar verirken bakacağız)
    final wasAceChain = gs.aceChainActive;
    final wasAceSuit = gs.aceChainSuit;

    // çıkar + yere at
    p.hand.remove(card);
    gs.pushDiscard(card);
    gs.markPlayedClubIfNeeded(p, card);

    // J için önceden seçilen suit geldiyse uygula
    if (card.isJack && jackChosen != null) {
      gs.selectedSuit = jackChosen;
    }

    // efektler
    RulesEngine.applyEffects(
      state: gs,
      card: card,
      firstClubPhase: gs.firstClubPhase,
      onAskSuitForJack: card.isJack ? () => gs.selectedSuit : null,
    );

    // sıra ilerletme kararı
    bool advanced = false;

    // 1) Ceza istifi (7/JJ): her zaman sırayı ilerlet
    if (gs.pendingPenalty > 0 &&
        (card.isSeven || card.type == CardType.jollyJoker)) {
      gs.nextTurn();
      advanced = true;
    }
    // 2) İlk tur: her zaman ilerlet (özel efektler kapalı, çoklu atış yok)
    else if (gs.firstClubPhase) {
      gs.nextTurn();
      advanced = true;
    }
    // 3) 8 skip / 10 bounce: her zaman ilerlet
    else if (card.isEight) {
      gs.nextTurn(step: 2);
      advanced = true;
    } else if (card.isTen) {
      gs.prevTurnOneStep();
      advanced = true;
    }
    // 4) SADECE As zinciri için çoklu atış:
    else {
      if (p.isHuman) {
        if (card.isAce) {
          // As atıldı → zincir başladı/devam etti → sıra sende kalsın
          advanced = false;
        } else if (wasAceChain &&
            card.type == CardType.standard &&
            card.suit == wasAceSuit &&
            !card.isAce) {
          // Zinciri suit kartıyla kırdın → tur otomatik biter
          gs.nextTurn();
          advanced = true;
        } else {
          // As zinciri YOK → normalde sırayı ilerlet
          gs.nextTurn();
          advanced = true;
        }
      } else {
        // botlar çoklu atmaz
        gs.nextTurn();
        advanced = true;
      }
    }

    if (advanced) {
      _maybeBotTurn();
    }
    gs.notify();
    return true;
  }

  void drawOne() {
    final p = gs.current;

    // ceza varsa: toplamı çek ve turu düş
    if (gs.pendingPenalty > 0) {
      for (var i = 0; i < gs.pendingPenalty; i++) {
        p.hand.add(gs.drawOne());
      }
      gs.pendingPenalty = 0;
      gs.penaltyKind = PenaltyKind.none;
      gs.nextTurn();
      _maybeBotTurn();
      gs.notify();
      return;
    }

    // normal çek
    p.hand.add(gs.drawOne());
    gs.notify();
  }

  /// Tur sonlandır (insan zinciri kırmadan önce kendi isteğiyle de bitirebilir)
  void endTurn() {
    gs.nextTurn();
    _maybeBotTurn();
    gs.notify();
  }

  void pass() => endTurn();

  // ---------------- BOT DÖNGÜSÜ ----------------

  Future<void> _maybeBotTurn() async {
    if (_botRunning) return; // re-entrancy guard
    if (gs.current.isHuman) return;

    _botRunning = true;
    try {
      while (!gs.current.isHuman) {
        final bot = gs.current;

        // küçük insanî gecikme
        final delayMs = switch (settings.difficulty) {
          Difficulty.easy => 300,
          Difficulty.normal => 450,
          Difficulty.hard => 650,
        };
        await Future.delayed(Duration(milliseconds: delayMs));

        final decision = BotStrategy.decide(
          settings: settings,
          gs: gs,
          bot: bot,
        );

        if (decision.playCard != null) {
          final jackSuit = decision.jackChosenSuit;
          final ok = playCard(
            decision.playCard!,
            jackChosen: jackSuit,
            keepTurn: false,
          );
          if (!ok) {
            // güvenlik: oynayamazsa 1 kart çek ve turu düş
            bot.hand.add(gs.drawOne());
            gs.nextTurn();
          }
        } else if (decision.draw) {
          if (gs.pendingPenalty > 0) {
            // toplu çekmeyi drawOne() halleder
            drawOne();
          } else {
            // 1 kart çek
            bot.hand.add(gs.drawOne());
            gs.notify();

            // Çektikten sonra oynayabiliyorsa hemen oyna, yoksa turu geçir
            final playableAfter = bot.hand
                .where((c) => RulesEngine.isPlayable(state: gs, card: c))
                .toList();

            if (playableAfter.isNotEmpty) {
              final c = playableAfter.first;
              Suit? jackSuit;
              if (c.isJack && !gs.firstClubPhase) {
                jackSuit = _majoritySuit(bot.hand);
              }
              final ok = playCard(c, jackChosen: jackSuit, keepTurn: false);
              if (!ok) {
                gs.nextTurn();
              }
            } else {
              gs.nextTurn();
            }
          }
        } else if (decision.pass) {
          gs.nextTurn();
        }
      }
    } finally {
      _botRunning = false;
    }
  }

  // ---- yardımcılar ----

  Suit _majoritySuit(List<CardModel> hand) {
    final counts = <Suit, int>{for (final s in Suit.values) s: 0};
    for (final c in hand) {
      if (c.type == CardType.standard && c.suit != null) {
        counts[c.suit!] = (counts[c.suit!] ?? 0) + 1;
      }
    }
    Suit best = Suit.clubs;
    var max = -1;
    counts.forEach((s, n) {
      if (n > max) {
        max = n;
        best = s;
      }
    });
    return best;
  }
}
