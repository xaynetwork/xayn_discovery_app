import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/tts/translator.dart';

const Map<String, List<_UrlLanguage>> _locality = {
  'nl': [
    _UrlLanguage('nl', 'nl'),
    _UrlLanguage('be', 'be'),
  ],
  'de': [
    _UrlLanguage('de', 'de'),
    _UrlLanguage('at', 'at'),
    _UrlLanguage('ch', 'ch'),
  ],
  'fr': [
    _UrlLanguage('fr', 'fr'),
    _UrlLanguage('be', 'be'),
    _UrlLanguage('ch', 'ch'),
  ],
  'en': [
    _UrlLanguage('us', 'com'),
    _UrlLanguage('gb', 'co.uk'),
    _UrlLanguage('ca', 'ca'),
    _UrlLanguage('ga', 'ie'),
  ],
};

@injectable
class DetectLanguageUseCase extends UseCase<TextAndSource, LanguageCode> {
  final Translator _translator;

  DetectLanguageUseCase(this._translator);

  @override
  Stream<LanguageCode> transaction(TextAndSource param) async* {
    final translation = await _translator.translate(param.text);
    var code = translation.sourceLanguage.code;

    if (code == 'auto') code = 'en';

    var minor = _UrlLanguage(code, '*');

    if (_locality.containsKey(code)) {
      final minors = _locality[code]!;

      minor = minors.firstWhere(
          (it) => param.uri?.host.endsWith(it.fingerprint) == true,
          orElse: () => minors.first);
    }

    yield LanguageCode(major: code, minor: minor.code);
  }
}

class TextAndSource {
  final Uri? uri;
  final String text;

  const TextAndSource({
    required this.text,
    this.uri,
  });
}

class LanguageCode {
  final String major;
  final String minor;

  const LanguageCode({
    required this.major,
    required this.minor,
  });
}

class _UrlLanguage {
  final String code;
  final String fingerprint;

  const _UrlLanguage(
    this.code,
    this.fingerprint,
  );
}
