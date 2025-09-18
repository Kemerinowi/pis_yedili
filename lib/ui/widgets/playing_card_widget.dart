import 'package:flutter/material.dart';
import '../../core/card.dart';
import '../assets/card_assets.dart';

class PlayingCardWidget extends StatelessWidget {
  final double width;
  final CardModel card;
  final bool faceUp;
  final VoidCallback? onTap;
  final bool disabled; // <-- eklendi

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.faceUp = true,
    this.onTap,
    this.width = 70,
    this.disabled = false, // <-- eklendi
  });

  static const _aspect = 64 / 89;
  double get _height => width / _aspect;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: width,
      height: _height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 1.2),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6)],
          color: faceUp ? Colors.white : const Color(0xFF101418),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.5),
          child: faceUp ? _faceWithAssets() : _back(),
        ),
      ),
    );

    final faded = disabled ? Opacity(opacity: 0.55, child: content) : content;

    return GestureDetector(onTap: disabled ? null : onTap, child: faded);
  }

  Widget _back() => Center(
    child: Text(
      'PİS\nYEDİLİ',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 14,
        height: 1.0,
      ),
    ),
  );

  Widget _faceWithAssets() {
    if (card.type == CardType.jollyJoker) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                CardAssets.jolly(),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    _textFace('JOLLY\nJOKER', isRed: true),
              ),
            ),
            _badge('JJ'),
          ],
        ),
      );
    }

    final path = CardAssets.front(card.suit, card.rank);
    final isRed = (card.suit == Suit.hearts || card.suit == Suit.diamonds);

    if (path.isEmpty) return _textFace(card.display(), isRed: isRed);

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              path,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  _textFace(card.display(), isRed: isRed),
            ),
          ),
          _badge(card.display()),
        ],
      ),
    );
  }

  Widget _textFace(String text, {required bool isRed}) => Center(
    child: Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isRed ? Colors.red[700] : Colors.black,
        fontWeight: FontWeight.w800,
        fontSize: 14,
        height: 1.05,
      ),
    ),
  );

  Widget _badge(String label) => Positioned(
    right: 3,
    bottom: 2,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 8.5, color: Colors.white),
      ),
    ),
  );
}
