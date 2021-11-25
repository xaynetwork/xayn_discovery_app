import 'dart:developer';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';

@injectable
class HeuristicFilterUseCase extends UseCase<Elements, Elements> {
  @override
  Stream<Elements> transaction(Elements param) async* {
    yield Elements(
      processHtmlResult: param.processHtmlResult,
      images: param.images,
      paragraphs:
          param.paragraphs.where(_isValidParagraph).toList(growable: false),
    );
  }

  bool _isValidParagraph(String text) {
    /// todo: work in progress
    /// We are investigating an NLP solution with Pink
    /// meanwhile, this already filters out some very obvious paragraphs
    /// feel free to add checks when spotting clearly distinguishable bad paragraphs.
    final hasLetters = RegExp(r'[A-Za-z\u00C0-\u00FF]');
    final isScreaming = text.toUpperCase() == text;

    final isValid = !isScreaming && hasLetters.hasMatch(text);

    if (!isValid) {
      log('dismissed paragraph: $text');
    }

    return isValid;
  }
}
