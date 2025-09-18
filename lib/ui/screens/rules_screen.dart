import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kurallar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            '• 4 oyuncu (Sen + 3 bot)\n'
            '• 2×52 = 104 kart; J = Normal Joker (wild).\n'
            '• Jolly Joker modu açık ise her desteye 2 JJ eklenir (toplam 108).\n'
            '• İlk tur: herkes en az 1 kez ♣ atana kadar özel efektler kapalı; sınırsız çekebilirsin.\n'
            '• 7 → +3 (sadece 7 ile istif), JJ → +10 (sadece JJ ile istif), 8 → pas, 10 → tek adım geri.\n'
            '• As zinciri: As/As/…; son As’ın türüyle uyumlu As-dışı kart zinciri kırar.\n'
            '• Kart çekince aynı turda oynayıp oynamamak oyuncuya kalır.',
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
      ),
    );
  }
}
