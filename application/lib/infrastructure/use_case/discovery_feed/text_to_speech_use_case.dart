import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:translator/translator.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

typedef ParagraphList = List<String>;

@injectable
class TextToSpeechUseCase extends UseCase<ParagraphList, Duration> {
  final Tts _tts;

  TextToSpeechUseCase(this._tts);

  @override
  Stream<Duration> transaction(ParagraphList param) async* {
    if (param.isNotEmpty) {
      final translator = GoogleTranslator();

      await _tts.setVolume(1.0);

      detectLanguage(String text) async {
        final translation = await translator.translate(text);
        final languageCode = translation.sourceLanguage.code;

        final canSpeakInLanguage = await _tts.isLanguageAvailable(languageCode);

        return canSpeakInLanguage ? translation.sourceLanguage.code : null;
      }

      yield* Stream.fromIterable(param)
          .map((it) => it.trim())
          .where((it) => it.isNotEmpty)
          .asyncMap((it) async {
            final languageCode = await detectLanguage(it);

            if (languageCode != null) {
              await _tts.setLanguage(languageCode);

              return it;
            }

            return null;
          })
          .where((it) => it != null)
          .cast<String>()
          .asyncMap(_tts.speak)
          .mapTo(true)
          .asyncMap(_tts.awaitSpeakCompletion)
          .timeInterval()
          .map((it) => it.interval);
    }
  }

  Future<dynamic> stopCurrentSpeech() => _tts.stop();
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
