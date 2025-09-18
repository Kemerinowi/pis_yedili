// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pis Yedili';

  @override
  String get mainMenu => 'Main menu';

  @override
  String get players => 'Players';

  @override
  String get settingAutoPlayDrawn => 'Play drawn card in same turn';

  @override
  String get settingAutoPlayDrawnSub => 'Auto-play if playable';

  @override
  String get settingJackWild => 'Jack changes suit';

  @override
  String get settingJackWildSub => 'NJ is already wild; off by default';

  @override
  String get startGame => 'Start Game';

  @override
  String get yourTurn => 'Turn';

  @override
  String get penalty => 'Penalty';

  @override
  String get firstTour => 'First tour: everyone must play at least one club';

  @override
  String get drawCard => 'Draw';

  @override
  String get pass => 'Pass';

  @override
  String get chooseSuit => 'Choose suit';

  @override
  String get lastCard => 'Last card!';
}
