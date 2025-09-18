import 'package:flutter/material.dart';
import 'ui/screens/menu_screen.dart'; // veya senin ilk ekranın

void main() {
  runApp(const PisYediliApp());
}

class PisYediliApp extends StatelessWidget {
  const PisYediliApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);

    final theme = base.copyWith(
      // Button/Ink highlight ve ripple tamamen kapalı
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      // İstersen textTheme vs. burada özelleştirirsin
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pis Yedili',
      theme: theme,
      // Tüm scrollable’larda overscroll/stretch/glow yok + clamping fiziği
      scrollBehavior: const _NoGlowNoStretchScrollBehavior(),
      home: const MenuScreen(), // senin açılış ekranın
    );
  }
}

/// Tüm platformlarda overscroll glow/stretchi kaldırır, clamping fiziği kullanır.
class _NoGlowNoStretchScrollBehavior extends ScrollBehavior {
  const _NoGlowNoStretchScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // glow ve stretch yok
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics(); // iOS’ta bile clamping
  }
}
