abstract class TtsService {
  Future<dynamic> isLanguageAvailable(String language);
  Future<dynamic> setLanguage(String language);
  Future<dynamic> setVolume(double volume);
  Future<dynamic> speak(String text);
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion);
  Future<dynamic> stop();
}
