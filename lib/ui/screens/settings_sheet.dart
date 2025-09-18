import 'package:flutter/material.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Ayarlar / Bilgi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            '• JJ modu bu demo’da Menüden başlatırken açık.\n'
            '• Renk körlüğü modu, ses/haptics vb. eklenebilir.',
          ),
        ],
      ),
    );
  }
}
