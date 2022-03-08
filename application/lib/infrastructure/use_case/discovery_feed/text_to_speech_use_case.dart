import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

@injectable
class TextToSpeechUseCase extends UseCase<TextToSpeechUseCaseIn, Duration> {
  final Tts _tts;

  TextToSpeechUseCase(this._tts);

  @override
  Stream<Duration> transaction(TextToSpeechUseCaseIn param) async* {
    if (param.paragraphs.isNotEmpty) {
      final canSpeakInLanguage =
          await _tts.isLanguageAvailable(param.languageCode);

      if (canSpeakInLanguage) {
        await _tts.setLanguage(param.languageCode);
        await _tts.setVolume(1.0);

        yield* Stream.fromIterable(param.paragraphs)
            .asyncMap(_tts.speak)
            .mapTo(true)
            .asyncMap(_tts.awaitSpeakCompletion)
            .timeInterval()
            .map((it) => it.interval);
      }
    }
  }

  Future<dynamic> stopCurrentSpeech() => _tts.stop();
}

class TextToSpeechUseCaseIn {
  final String languageCode;
  final List<String> paragraphs;

  const TextToSpeechUseCaseIn({
    required this.languageCode,
    required this.paragraphs,
  });
}

abstract class Tts {
  Future<dynamic> isLanguageAvailable(String language);
  Future<dynamic> setLanguage(String language);
  Future<dynamic> setVolume(double volume);
  Future<dynamic> speak(String text);
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion);
  Future<dynamic> stop();
}

@Injectable(as: Tts)
class AppTts implements Tts {
  late final FlutterTts _impl = FlutterTts();

  @override
  Future awaitSpeakCompletion(bool awaitCompletion) =>
      _impl.awaitSpeakCompletion(awaitCompletion);

  @override
  Future isLanguageAvailable(String language) =>
      _impl.isLanguageAvailable(language);

  @override
  Future setLanguage(String language) => _impl.setLanguage(language);

  @override
  Future setVolume(double volume) => _impl.setVolume(volume);

  @override
  Future speak(String text) => _impl.speak(text);

  @override
  Future stop() => _impl.stop();
}
