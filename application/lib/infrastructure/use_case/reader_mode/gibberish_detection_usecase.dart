import 'package:country_code/country_code.dart';
import 'package:franc/franc.dart';
import 'package:gibberish/gibberish.dart';
import 'package:gibberish/language.dart';
import 'package:html/parser.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/remote_content/processed_document.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/string_utils.dart';

@injectable
class GibberishDetectionUseCase
    extends UseCase<ProcessedDocument, ProcessedDocument> {
  final Franc franc;

  GibberishDetectionUseCase._(this.franc);

  factory GibberishDetectionUseCase.testing(Franc franc) =>
      GibberishDetectionUseCase._(franc);

  factory GibberishDetectionUseCase() => GibberishDetectionUseCase._(Franc());

  @override
  Stream<ProcessedDocument> transaction(ProcessedDocument param) async* {
    var contents = param.processHtmlResult.contents;
    final watch = Stopwatch();
    watch.start();

    // Text is too short, its gibberish
    if (contents == null || contents.isEmpty == true) {
      yield ProcessedDocument(
        processHtmlResult: param.processHtmlResult,
        timeToRead: param.timeToRead,
        isGibberish: true,
      );
      logger.i('❌ Text is too short, its gibberish');
      return;
    }

    contents = parse(contents)
        .querySelectorAll('*')
        .map((e) => e.text)
        .reduce((value, element) => element + value);
    final languages = await franc.detectLanguages(contents);
    final detectedLanguage = languages.keys.first;
    // Text is written in a language that is unknown to the world, so it must be gibberish
    if (detectedLanguage == "und") {
      yield ProcessedDocument(
        processHtmlResult: param.processHtmlResult,
        timeToRead: param.timeToRead,
        isGibberish: true,
      );
      logger.i('❌ Text is undetectable');
      return;
    }

    final metaLanguage = param.processHtmlResult.lang;
    final language = detectedLanguage.toGibberishLanguage ??
        metaLanguage?.toGibberishLanguage;
    // We detected that this is part of a language that we don't support in the app,
    // so we don't really know if it is gibberish
    if (language == null) {
      yield ProcessedDocument(
        processHtmlResult: param.processHtmlResult,
        timeToRead: param.timeToRead,
        isGibberish: null,
        detectedLanguage: detectedLanguage,
      );
      logger.i(
          'Text is $detectedLanguage (meta data: $metaLanguage), but we don\'t support that');
      return;
    }

    // Default case, we are supporting the document language and the detection
    // can do its job
    final gibberishCandidate = analyze(language, contents);
    yield ProcessedDocument(
      processHtmlResult: param.processHtmlResult,
      timeToRead: param.timeToRead,
      isGibberish: gibberishCandidate.isGibberish,
      detectedLanguage: detectedLanguage,
    );
    watch.stop();
    logger.i(
        'Text is $detectedLanguage (time: ${watch.elapsed}, meta lang: $metaLanguage) : $gibberishCandidate\n\n${gibberishCandidate.isGibberish ? contents : contents.truncate(1000)}');
  }
}

final localeLanguage = RegExp(r'^[a-zA-Z]{2}[-_][a-zA-Z]{2}$');
final twoLetterLanguage = RegExp(r'^[a-zA-Z]{2}$');
final localeSplit = RegExp('[-_]');

extension on String {
  Language? get toGibberishLanguage {
    String? lang = trim();
    if (localeLanguage.hasMatch(lang)) {
      lang = split(localeSplit)[0].toThreeLetterLang;
    } else if (twoLetterLanguage.hasMatch(lang)) {
      lang = toThreeLetterLang;
    }

    switch (lang) {
      case 'eng':
        return Language.english;
      case 'deu':
        return Language.german;
      case 'esp':
        return Language.spanish;
      case 'nld':
        return Language.dutch;
      case 'pol':
        return Language.polish;
      case 'fra':
        return Language.french;
      default:
        return null;
    }
  }

  String? get toThreeLetterLang =>
      CountryCode.tryParse(toUpperCase())?.alpha3.toLowerCase();
}
