import 'package:injectable/injectable.dart';
import 'package:translator/translator.dart';
import 'package:xayn_discovery_app/domain/tts/translator.dart';

@Injectable(as: Translator)
class AppTranslator implements Translator {
  late final GoogleTranslator _impl = GoogleTranslator();

  @override
  Future<Translation> translate(
    String sourceText, {
    String from = 'auto',
    String to = 'en',
  }) =>
      _impl.translate(
        sourceText,
        from: from,
        to: to,
      );
}
