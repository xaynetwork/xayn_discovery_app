import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/load_html_use_case.dart';
import 'package:xayn_readability/xayn_readability.dart';

Matcher progressSuccess(Progress out) => _ProgressSuccess(out);
Matcher testHtmlSuccess(Progress out, bool Function(String html) testHtml) =>
    _TestHtmlSuccess(out, testHtml);
Matcher elementsSuccess(Elements out) => _ElementsSuccess(out);
Matcher processHtmlSuccess(ProcessHtmlResult out) => _ProcessHtmlSuccess(out);

class _ProgressSuccess extends Matcher {
  final Progress _expected;

  const _ProgressSuccess(this._expected);

  @override
  bool matches(item, Map matchState) {
    bool isMatched = false;

    if (item is UseCaseResult<Progress>) {
      item.fold(
        defaultOnError: (e, s) {},
        onValue: (it) => isMatched = _expected.isCompleted == it.isCompleted &&
            _expected.html == it.html &&
            _expected.uri == it.uri,
      );
    }

    return isMatched;
  }

  @override
  Description describe(Description description) =>
      description.add('matches ').addDescriptionOf(_expected);
}

class _TestHtmlSuccess extends Matcher {
  final Progress _expected;
  final bool Function(String html) _testHtml;

  const _TestHtmlSuccess(
    this._expected,
    this._testHtml,
  );

  @override
  bool matches(item, Map matchState) {
    bool isMatched = false;

    if (item is UseCaseResult<Progress>) {
      item.fold(
        defaultOnError: (e, s) {},
        onValue: (it) => isMatched = _expected.isCompleted == it.isCompleted &&
            _testHtml(it.html) &&
            _expected.uri == it.uri,
      );
    }

    return isMatched;
  }

  @override
  Description describe(Description description) =>
      description.add('matches ').addDescriptionOf(_expected);
}

class _ProcessHtmlSuccess extends Matcher {
  final ProcessHtmlResult _expected;

  const _ProcessHtmlSuccess(this._expected);

  @override
  bool matches(item, Map matchState) {
    bool isMatched = false;

    if (item is UseCaseResult<ProcessHtmlResult>) {
      item.fold(
          defaultOnError: (e, s) {},
          onValue: (it) => isMatched = _expected.contents == it.contents &&
              _expected.themeColor == it.themeColor &&
              _expected.textSize == it.textSize);
    }

    return isMatched;
  }

  @override
  Description describe(Description description) =>
      description.add('matches ').addDescriptionOf(_expected);
}

class _ElementsSuccess extends Matcher {
  final Elements _expected;

  const _ElementsSuccess(this._expected);

  @override
  bool matches(item, Map matchState) {
    bool isMatched = false;

    if (item is UseCaseResult<Elements>) {
      item.fold(
          defaultOnError: (e, s) {},
          onValue: (it) =>
              isMatched = listEquals(_expected.paragraphs, it.paragraphs) &&
                  processHtmlSuccess(_expected.processHtmlResult).matches(
                    UseCaseResult.success(it.processHtmlResult),
                    matchState,
                  ));
    }

    return isMatched;
  }

  @override
  Description describe(Description description) =>
      description.add('matches ').addDescriptionOf(_expected);
}
