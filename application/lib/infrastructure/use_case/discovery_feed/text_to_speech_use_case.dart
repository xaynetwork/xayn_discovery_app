import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/tts/tts.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/detect_language_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

@injectable
class TextToSpeechUseCase extends UseCase<Utterance, Duration> {
  final Tts _tts;
  final DetectLanguageUseCase _detectLanguageUseCase;

  TextToSpeechUseCase(this._tts, this._detectLanguageUseCase);

  @override
  Stream<Duration> transaction(Utterance param) async* {
    yield* Stream.fromIterable(param.paragraphs)
        .map((it) => it.trim())
        .where((it) => it.isNotEmpty)
        .asyncMap((it) => _resolveLanguage(it, param.uri))
        .where((it) => it != null)
        .cast<String>()
        .asyncMap(_tts.speak)
        .mapTo(true)
        .asyncMap(_tts.awaitSpeakCompletion)
        .timeInterval()
        .map((it) => it.interval);
  }

  Future<dynamic> stopCurrentSpeech() => _tts.stop();

  Future<String?> _detectLanguage(String text, Uri? uri) async {
    final languageCode = await _detectLanguageUseCase.singleOutput(
      TextAndSource(
        text: text,
        uri: uri,
      ),
    );
    final codeA = '${languageCode.major}-${languageCode.minor.toUpperCase()}';
    final codeB = languageCode.major;

    if (await _tts.isLanguageAvailable(codeA)) {
      return codeA;
    } else if (await _tts.isLanguageAvailable(codeB)) {
      return codeB;
    }

    return null;
  }

  Future<String?> _resolveLanguage(String text, Uri? uri) async {
    final languageCode = await _detectLanguage(text, uri);

    if (languageCode != null) {
      logger.i('will speak in [$languageCode]');

      await _tts.setLanguage(languageCode);

      return text;
    }

    return null;
  }
}

class Utterance {
  final List<String> paragraphs;
  final Uri? uri;

  const Utterance({
    required this.paragraphs,
    this.uri,
  });
}
