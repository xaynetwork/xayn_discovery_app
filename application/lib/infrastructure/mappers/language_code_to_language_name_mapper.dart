import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

@lazySingleton
class LanguageCodeToLanguageNameMapper extends Mapper<String, String?> {
  @override
  String? map(String input) {
    switch (input) {
      case SupportedLanguageCodes.dutch:
        return R.strings.langNameDutch;
      case SupportedLanguageCodes.english:
        return R.strings.langNameEnglish;
      case SupportedLanguageCodes.french:
        return R.strings.langNameFrench;
      case SupportedLanguageCodes.german:
        return R.strings.langNameGerman;
      case SupportedLanguageCodes.polish:
        return R.strings.langNamePolish;
      case SupportedLanguageCodes.spanish:
        return R.strings.langNameSpanish;
      default:
        return null;
    }
  }
}
