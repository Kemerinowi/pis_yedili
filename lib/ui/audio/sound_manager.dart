import 'package:flutter/services.dart';

/// Bazı platformlarda (web/desktop) HapticFeedback henüz implement edilmemiş olabilir.
/// Bu durumda UnimplementedError fırlatır; biz bu hatayı yutuyoruz.
class SoundManager {
  static Future<void> _safe(Future<void> Function() call) async {
    try {
      await call();
    } catch (_) {
      // UnimplementedError veya platform hataları burada sessizce yutulur
    }
  }

  static Future<void> invalid() => _safe(HapticFeedback.heavyImpact);
  static Future<void> play() => _safe(HapticFeedback.selectionClick);
  static Future<void> draw() => _safe(HapticFeedback.lightImpact);
  static Future<void> penalty() => _safe(HapticFeedback.heavyImpact);
}
