import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_architecture/concepts/use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/load_html_use_case.dart';
import 'package:xayn_readability/xayn_readability.dart';

Matcher progressSuccess(Progress out) => _ProgressSuccess(out);
Matcher elementsSuccess(Elements out) => _ElementsSuccess(out);
Matcher processHtmlSuccess(ProcessHtmlResult out) => _ProcessHtmlSuccess(out);

class _ProgressSuccess extends Matcher {
  final Progress _expected;

  const _ProgressSuccess(this._expected);

  @override
  bool matches(item, Map matchState) {
    if (item is UseCaseResult<Progress>) {
      return _expected.isCompleted == item.data?.isCompleted &&
          _expected.html == item.data?.html &&
          _expected.uri == item.data?.uri;
    }

    return false;
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
    if (item is UseCaseResult<ProcessHtmlResult>) {
      return _expected.contents == item.data?.contents &&
          _expected.themeColor == item.data?.themeColor &&
          _expected.textSize == item.data?.textSize;
    }

    return false;
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
    if (item is UseCaseResult<Elements>) {
      return listEquals(_expected.paragraphs, item.data?.paragraphs) &&
          listEquals(_expected.images, item.data?.images) &&
          processHtmlSuccess(_expected.processHtmlResult).matches(
            UseCaseResult.success(item.data?.processHtmlResult),
            matchState,
          );
    }

    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('matches ').addDescriptionOf(_expected);
}
