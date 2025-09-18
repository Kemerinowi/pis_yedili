import '../../core/card.dart';

class CardAssets {
  static const _base = 'assets/pis_yedili_basic_pack/pis_yedili_assets';

  static const backDark = '$_base/backs/back_dark.png';
  static const backRed = '$_base/backs/back_red.png';

  static String jolly() => '$_base/jokers/jolly_joker_1.png';

  /// Kart yüzü dosya yolu.
  /// HATALI/eksik veri gelirse "" döner (widget metin fallback gösterir).
  static String front(Suit? suit, Rank? rank) {
    if (suit == null || rank == null) return "";

    String s;
    switch (suit) {
      case Suit.clubs:
        s = 'clubs';
        break; // veya 'sinek' -> paket adına göre
      case Suit.diamonds:
        s = 'diamonds';
        break; // 'karo'
      case Suit.hearts:
        s = 'hearts';
        break; // 'kupa'
      case Suit.spades:
        s = 'spades';
        break; // 'maca'
    }

    String r;
    switch (rank) {
      case Rank.ace:
        r = 'A';
        break;
      case Rank.r2:
        r = '2';
        break;
      case Rank.r3:
        r = '3';
        break;
      case Rank.r4:
        r = '4';
        break;
      case Rank.r5:
        r = '5';
        break;
      case Rank.r6:
        r = '6';
        break;
      case Rank.r7:
        r = '7';
        break;
      case Rank.r8:
        r = '8';
        break;
      case Rank.r9:
        r = '9';
        break;
      case Rank.r10:
        r = '10';
        break;
      case Rank.jack:
        r = 'J';
        break;
      case Rank.queen:
        r = 'Q';
        break;
      case Rank.king:
        r = 'K';
        break;
    }

    // Paketindeki dosya adları farklıysa (ör. sinek_A.png) yalnızca s ve r’yi yukarıda değiştirmen yeterli.
    return '$_base/deck1/${s}_$r.png';
  }
}
