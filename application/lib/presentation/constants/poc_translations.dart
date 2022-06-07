import 'package:xayn_discovery_app/presentation/constants/app_language.dart';

class PocTranslations {
  const PocTranslations();

  String get feedModeSectionTitle => "Feed Mode";
  String get feedModeStream => "Stream";
  String get feedModeCarousel => "Carousel";
}

class PocTranslationsDe extends PocTranslations {
  const PocTranslationsDe();
  @override
  String get feedModeSectionTitle => "Feed Mode auf Deutsch";
  @override
  String get feedModeStream => "Stream auf Deutsch";
  @override
  String get feedModeCarousel => "Carousel auf Deutsch";
}

extension AppLanguageExtension on AppLanguage {
  PocTranslations get pocTranslations {
    switch (this) {
      case AppLanguage.german:
        return const PocTranslationsDe();
      case AppLanguage.english:
      case AppLanguage.dutch:
      case AppLanguage.french:
      case AppLanguage.polish:
      case AppLanguage.spanish:
        return const PocTranslations();
    }
  }
}
