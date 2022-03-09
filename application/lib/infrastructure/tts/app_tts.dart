import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/tts/tts.dart';

@Injectable(as: Tts)
class AppTts implements Tts {
  late final FlutterTts _impl = FlutterTts();

  AppTts() {
    _impl.setVolume(1.0);
  }

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
