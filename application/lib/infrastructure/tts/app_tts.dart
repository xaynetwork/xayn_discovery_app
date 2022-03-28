import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/tts/tts_service.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';

@Injectable(as: TtsService)
@releaseEnvironment
@debugEnvironment
class AppTtsService implements TtsService {
  late final _impl = FlutterTts();

  AppTtsService() {
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

@Injectable(as: TtsService)
@test
class TestAppTtsService implements TtsService {
  @override
  Future awaitSpeakCompletion(bool awaitCompletion) {
    throw UnimplementedError();
  }

  @override
  Future isLanguageAvailable(String language) {
    throw UnimplementedError();
  }

  @override
  Future setLanguage(String language) {
    throw UnimplementedError();
  }

  @override
  Future setVolume(double volume) {
    throw UnimplementedError();
  }

  @override
  Future speak(String text) {
    throw UnimplementedError();
  }

  @override
  Future stop() {
    throw UnimplementedError();
  }
}
