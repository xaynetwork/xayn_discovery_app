import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/story_mode/paragraph_rejected_reason.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';

const int kMinWordCount = 10;

@injectable
class HeuristicFilterUseCase extends UseCase<Elements, Elements> {
  final int minWordCount;
  final Pattern nonAlphanumerical = RegExp(r'\W');
  final Pattern matchLink =
      RegExp(r'''http[s]*:\/\/[A-Za-z0-9-._~:\/?#\[\]@!$&\'\(\)*+,;=]+''');

  HeuristicFilterUseCase({
    this.minWordCount = kMinWordCount,
  });

  @factoryMethod
  HeuristicFilterUseCase.standard() : minWordCount = kMinWordCount;

  @override
  Stream<Elements> transaction(Elements param) async* {
    final validParagraphs = <String>[];

    for (var paragraph in param.paragraphs) {
      try {
        _runAllFilters(paragraph);
        validParagraphs.add(paragraph);
      } on FilterException {
        // read out any errors when optimizing filters
      }
    }

    if (validParagraphs.isEmpty) {
      throw const FilterAggregateException();
    }

    yield Elements(
      processHtmlResult: param.processHtmlResult,
      paragraphs: validParagraphs,
    );
  }

  bool isTooShort(String text) =>
      text.split(nonAlphanumerical).length < minWordCount;

  bool isScreaming(String text) => text.toUpperCase() == text;

  bool containsMostlyLinks(String text) {
    final allLinks =
        matchLink.allMatches(text).map((it) => it.group(0)).join('');
    final sizeWithoutLinks = text.length - allLinks.length;

    return allLinks.length >= sizeWithoutLinks;
  }

  void _runAllFilters(String paragraph) {
    test({
      required bool Function(String text) predicate,
      required String text,
      required ParagraphRejectedReason reasonWhenRejected,
    }) {
      if (predicate(text)) {
        throw FilterException(text, reasonWhenRejected);
      }
    }

    test(
      predicate: isTooShort,
      text: paragraph,
      reasonWhenRejected: ParagraphRejectedReason.notEnoughWords,
    );

    test(
      predicate: isScreaming,
      text: paragraph,
      reasonWhenRejected: ParagraphRejectedReason.allUppercase,
    );

    test(
      predicate: containsMostlyLinks,
      text: paragraph,
      reasonWhenRejected: ParagraphRejectedReason.containsMostlyLinks,
    );
  }
}

class FilterException extends Error {
  final String paragraph;
  final ParagraphRejectedReason rejectionReason;

  String get message =>
      '$paragraph did not pass the test because $rejectionReason';

  FilterException(this.paragraph, this.rejectionReason);

  @override
  String toString() => message;
}

class FilterAggregateException {
  String get message => 'not a single paragraph passed the filter';

  const FilterAggregateException();

  @override
  String toString() => message;
}
