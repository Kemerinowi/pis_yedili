import 'package:flutter/material.dart';
import '../../game/game_settings.dart';
import '../../game/game_controller.dart';
import 'play_screen.dart';
import 'rules_screen.dart';
import 'settings_sheet.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Difficulty _difficulty = Difficulty.normal;
  bool _useJollyJoker = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'PİS YEDİLİ',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 24),

                  // Difficulty selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Zorluk:  '),
                      DropdownButton<Difficulty>(
                        value: _difficulty,
                        onChanged: (v) => setState(
                          () => _difficulty = v ?? Difficulty.normal,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: Difficulty.easy,
                            child: Text('Kolay'),
                          ),
                          DropdownMenuItem(
                            value: Difficulty.normal,
                            child: Text('Normal'),
                          ),
                          DropdownMenuItem(
                            value: Difficulty.hard,
                            child: Text('Zor'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // JJ toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Jolly Joker (+10)'),
                      Switch(
                        value: _useJollyJoker,
                        onChanged: (v) => setState(() => _useJollyJoker = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Oyunu Başlat'),
                    onPressed: () {
                      final settings = GameSettings(
                        useJollyJoker: _useJollyJoker,
                        difficulty: _difficulty,
                      );
                      final controller = GameController(settings);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayScreen(controller: controller),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Kurallar'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RulesScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text('Ayarlar (Bilgi)'),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (_) => const SettingsSheet(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
