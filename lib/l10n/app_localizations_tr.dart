// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Pis Yedili';

  @override
  String get mainMenu => 'Ana menü';

  @override
  String get players => 'Oyuncu';

  @override
  String get settingAutoPlayDrawn => 'Kart çekince aynı turda oynat';

  @override
  String get settingAutoPlayDrawnSub => 'Çekilen kart uygunsa otomatik at';

  @override
  String get settingJackWild => 'Vale tür değiştirir';

  @override
  String get settingJackWildSub =>
      'NJ zaten wild, bu seçenek varsayılan kapalıdır';

  @override
  String get startGame => 'Oyunu Başlat';

  @override
  String get yourTurn => 'Sıradaki';

  @override
  String get penalty => 'Ceza';

  @override
  String get firstTour => 'İlk tur: herkes en az bir sinek atmalı';

  @override
  String get drawCard => 'Kart Çek';

  @override
  String get pass => 'Pas';

  @override
  String get chooseSuit => 'Tür seç';

  @override
  String get lastCard => 'Son kart!';
}
