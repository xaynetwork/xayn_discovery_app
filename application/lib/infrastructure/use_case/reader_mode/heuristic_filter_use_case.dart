import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';

const int kMinWordCount = 10;

enum FailureReason {
  notEnoughWords,
  allUppercase,
  containsMostlyLinks,
}

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
  Stream<Elements> transaction(Elements param) {
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

    return Stream.value(Elements(
      processHtmlResult: param.processHtmlResult,
      paragraphs: validParagraphs,
    ));
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
      required FailureReason failureReason,
    }) {
      if (predicate(text)) {
        throw FilterException(text, failureReason);
      }
    }

    test(
      predicate: isTooShort,
      text: paragraph,
      failureReason: FailureReason.notEnoughWords,
    );

    test(
      predicate: isScreaming,
      text: paragraph,
      failureReason: FailureReason.allUppercase,
    );

    test(
      predicate: containsMostlyLinks,
      text: paragraph,
      failureReason: FailureReason.containsMostlyLinks,
    );
  }
}

class FilterException extends Error {
  final String paragraph;
  final FailureReason reason;

  String get message => '$paragraph did not pass the test because $reason';

  FilterException(this.paragraph, this.reason);

  @override
  String toString() => message;
}

class FilterAggregateException {
  String get message => 'not a single paragraph passed the filter';

  const FilterAggregateException();

  @override
  String toString() => message;
}
