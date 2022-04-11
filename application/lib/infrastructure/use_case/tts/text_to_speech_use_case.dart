import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/tts/tts_service.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

/// A map which can be used to try and further localize the language
/// code that we get from the engine, for example, try to resolve into nl-BE
/// if the resource is hosted in Belgium.
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
class TextToSpeechUseCase extends UseCase<Utterance, Duration> {
  final TtsService _tts;

  TextToSpeechUseCase(this._tts);

  Future<dynamic> stopCurrentSpeech() => _tts.stop();

  @override
  Stream<Duration> transaction(Utterance param) async* {
    yield* Stream.fromIterable(param.paragraphs)
        .map((it) => it.trim())
        .where((it) => it.isNotEmpty)
        .asyncMap((it) => _resolveLanguage(it, param.languageCode, param.uri))
        .asyncMap(_tts.speak)
        .mapTo(true)
        .asyncMap(_tts.awaitSpeakCompletion)
        .timeInterval()
        .map((it) => it.interval);
  }

  Future<String> _resolveLanguage(
    String text,
    String languageCode,
    Uri? uri,
  ) async {
    var code = languageCode;

    if (_locality.containsKey(code)) {
      final minors = _locality[code]!;
      final minor = minors.firstWhere(
          (it) => uri?.host.endsWith(it.fingerprint) == true,
          orElse: () => minors.first);

      code = '$code-${minor.code.toUpperCase()}';
    }

    logger.i('will speak in [$code]');

    await _tts.setLanguage(code);

    return text;
  }
}

class Utterance {
  final List<String> paragraphs;
  final String languageCode;
  final Uri? uri;

  const Utterance({
    required this.paragraphs,
    required this.languageCode,
    this.uri,
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
