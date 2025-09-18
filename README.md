# Pis Yedili (Flutter)

Derlenebilir, telifsiz asset’lerle gelen, offline botlara karşı “Pis Yedili” oyunu.

Özellikler
- 2×52 deste + 4×Jolly Joker + 8×Normal Joker = 116 kart
- 2–6 oyuncu (varsayılan 4); tek kaybeden kuralı (eli bitirenler oyundan çıkar)
- İlk tur “Sinek atma” kuralı (özel kart etkileri kapalıyken)
- Özel kartlar: 7(+3, istif), JJ(+10, istif), NJ(wild), 8(skip), 10(tek adım geri), As zinciri
- Ceza istifleme: 7 ↔ sadece 7, JJ ↔ sadece JJ
- Deste bitince atılanlar karıştırılıp yeni deste yapılır (üstteki kalır)
- 3 zorlukta bot: Basit / Normal / Zor (300–900 ms gecikme)
- Ayarlar: çekilen kartı aynı turda oynatma, “Vale tür değiştirir” opsiyonu, bot hızı
- TR/EN yerelleştirme (ARB), erişilebilir renk ikonları

Mimari
- core/: kart modeli, deste üretimi, kurallar motoru
- game/: durum modeli + Riverpod kontrollleri, bot stratejileri
- ui/: menü + oyun ekranı + kart bileşenleri
- assets/: SVG sırt, masa dokusu, semboller, JJ/NJ görselleri

Kurallar (özet)
- İlk tur: herkes en az bir kez Sinek(♣) atana kadar sürer, tüm özel etkiler kapalıdır. İsteyen sınırsız çekip pas geçebilir.
- Oynama: aynı tür veya aynı sayı; NJ wild (tür seçer, ceza vermez); J tür değiştirir opsiyonu varsayılan kapalı.
- 7: sonraki oyuncu +3; yalnız 7 ile istiflenir. JJ ile savunulamaz.
- JJ: sonraki oyuncu +10; yalnız JJ ile istiflenir. 7 ile karışmaz.
- 8: sonraki oyuncu atlanır.
- 10: tek adımlık geri sıçrama; yön kalıcı değişmez.
- As: zincir başlatır (herhangi bir As ile devam); en son As’ın türü geçerlidir; o türden As olmayan kart atılınca zincir biter. Zincir aktifken diğer özel etkiler devre dışıdır.
- Ceza: uygun kartla istife devam edemeyen oyuncu toplam cezayı çeker ve turunu kaybeder.

Çalıştırma
- Flutter stable gerektirir.
- `flutter pub get`
- `flutter run`

Testler
- `flutter test` ile 10+ unit ve 3 widget testi örneği.

Notlar
- Kart yüzleri programatik olarak suit ikonları + yazı ile çizilir. Tüm suit ikonları, kart sırtı ve masa deseni telifsiz SVG olarak `/assets` altında yer alır.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
