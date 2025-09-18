import 'package:flutter/material.dart';
import '../../core/card.dart';
import '../../game/game_controller.dart';
import '../../game/game_state.dart';
import '../audio/sound_manager.dart';
import '../widgets/playing_card_widget.dart';
import '../../core/rules_engine.dart';

class PlayScreen extends StatefulWidget {
  final GameController controller;
  const PlayScreen({super.key, required this.controller});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  GameState get gs => widget.controller.gs;

  // Kart genişlikleri (yükseklik oranla hesaplanır)
  static const double _wTop = 44; // üst botlar
  static const double _wSide = 56; // sol/sağ
  static const double _wCenter = 72; // masa
  static const double _wHand = 64; // bizim el
  static double _h(double w) => w / (64 / 89);

  @override
  void initState() {
    super.initState();
    gs.addListener(_onState);
  }

  @override
  void dispose() {
    gs.removeListener(_onState);
    super.dispose();
  }

  void _onState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final top = gs.discardPile.isNotEmpty ? gs.discardPile.last : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Masa'),
        actions: [
          if (gs.firstClubPhase)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  'İlk tur: SİNEK dön!',
                  style: TextStyle(color: Colors.amber),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _botRow(gs.players[2]),
            const SizedBox(height: 8),

            // Orta masa
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (gs.selectedSuit != null && !gs.firstClubPhase)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          'Seçili Tür: ${_suitText(gs.selectedSuit!)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PlayingCardWidget(
                          card: const CardModel.jolly(),
                          faceUp: false,
                          width: _wCenter,
                          onTap: () {
                            widget.controller.drawOne();
                            SoundManager.draw();
                          },
                        ),
                        const SizedBox(width: 24),
                        if (top != null)
                          PlayingCardWidget(
                            card: top,
                            faceUp: true,
                            width: _wCenter,
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (gs.pendingPenalty > 0)
                      Text(
                        'Cezalar: +${gs.pendingPenalty}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      'Sıra: ${gs.current.name}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            // Sol & Sağ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sidePile(gs.players[1], left: true),
                  _sidePile(gs.players[3], left: false),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Bizim el
            _bottomHand(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ---------- Bölümler ----------

  Widget _botRow(Player p) {
    final active = gs.players[gs.turnIndex] == p;
    return Column(
      children: [
        Text(
          '${p.name}  (${p.hand.length})',
          style: TextStyle(
            color: active ? Colors.amber : Colors.white70,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: _h(_wTop),
          width: double.infinity,
          child: ScrollConfiguration(
            behavior: const _NoStretchBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              physics: const ClampingScrollPhysics(), // <-- stretch/glow yok
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  p.hand.length,
                  (_) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: PlayingCardWidget(
                      card: CardModel.jolly(),
                      faceUp: false,
                      width: _wTop,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sidePile(Player p, {required bool left}) {
    final cards = (p.hand.length.clamp(0, 5)) as int;
    final totalW = _wSide + 8.0 * (cards - 1).clamp(0, 4);
    return Column(
      children: [
        Text(
          '${p.name}  (${p.hand.length})',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: totalW,
          height: _h(_wSide),
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(
              cards,
              (i) => Positioned(
                left: left ? i * 8.0 : null,
                right: left ? null : i * 8.0,
                child: const PlayingCardWidget(
                  card: CardModel.jolly(),
                  faceUp: false,
                  width: _wSide,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomHand() {
    final me = gs.players[0];
    final myTurn = gs.current == me;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: myTurn ? () => widget.controller.drawOne() : null,
              icon: const Icon(Icons.download),
              label: const Text('ÇEK'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: myTurn ? () => widget.controller.pass() : null,
              icon: const Icon(Icons.stop),
              label: const Text('TUR BİTİR'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: _h(_wHand),
          width: double.infinity,
          child: ScrollConfiguration(
            behavior: const _NoStretchBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const ClampingScrollPhysics(), // <-- stretch/glow yok
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(me.hand.length, (i) {
                  final c = me.hand[i];
                  final playable = RulesEngine.isPlayable(state: gs, card: c);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: PlayingCardWidget(
                      card: c,
                      faceUp: true,
                      width: _wHand,
                      disabled: !playable,
                      onTap: (!myTurn || !playable)
                          ? null
                          : () async {
                              Suit? chosen;
                              if (c.isJack && !gs.firstClubPhase) {
                                chosen = await _chooseSuit(context);
                                if (chosen != null) gs.selectedSuit = chosen;
                              }
                              final ok = widget.controller.playCard(
                                c,
                                jackChosen: chosen,
                                keepTurn:
                                    true, // controller sadece As zincirinde tutar
                              );
                              if (!ok) {
                                SoundManager.invalid();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Bu kartı şu an oynayamazsın.',
                                    ),
                                  ),
                                );
                              } else {
                                SoundManager.play();
                              }
                            },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _suitText(Suit s) => switch (s) {
    Suit.clubs => 'Sinek ♣',
    Suit.diamonds => 'Karo ♦',
    Suit.hearts => 'Kupa ♥',
    Suit.spades => 'Maça ♠',
  };

  Future<Suit?> _chooseSuit(BuildContext context) async {
    Suit? selected;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tür Seç (J)'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Suit.values.map((s) {
            return ElevatedButton(
              onPressed: () {
                selected = s;
                Navigator.of(context).pop();
              },
              child: Text(_suitText(s)),
            );
          }).toList(),
        ),
      ),
    );
    return selected;
  }
}

// Overscroll/stretch/glow'ı tamamen kapatır
class _NoStretchBehavior extends ScrollBehavior {
  const _NoStretchBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // hiç glow/strech yok
  }
}
