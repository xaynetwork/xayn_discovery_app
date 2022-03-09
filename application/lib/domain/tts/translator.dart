import 'package:translator/translator.dart';

abstract class Translator {
  Future<Translation> translate(
    String sourceText, {
    String from = 'auto',
    String to = 'en',
  });
}
