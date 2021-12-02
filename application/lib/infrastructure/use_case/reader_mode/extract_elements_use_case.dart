import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_readability/xayn_readability.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';

const String kSplitIndicator = '...';
const int kMaxParagraphSizeInChars = 260;

/// A [UseCase] which extracts any html elements as a List,
/// so that they can be loaded sequentially, as opposed to as an html tree.
@injectable
class ExtractElementsUseCase extends UseCase<ProcessHtmlResult, Elements> {
  final String splitIndicator;
  final int maxParagraphSize;

  ExtractElementsUseCase({
    this.splitIndicator = kSplitIndicator,
    this.maxParagraphSize = kMaxParagraphSizeInChars,
  });

  @factoryMethod
  ExtractElementsUseCase.standard()
      : splitIndicator = kSplitIndicator,
        maxParagraphSize = kMaxParagraphSizeInChars;

  @override
  Stream<Elements> transaction(ProcessHtmlResult param) async* {
    final html = param.contents;
    final result = html != null
        ? await compute(
            _processHtml,
            _IsolateParams(
              html: html,
              splitIndicator: splitIndicator,
              maxParagraphSize: maxParagraphSize,
            ))
        : null;

    yield Elements(
      processHtmlResult: param,
      paragraphs: result ?? const [],
    );
  }
}

/// Standalone Function which can be used as a target for [compute].
List<String> _processHtml(final _IsolateParams params) {
  final document = dom.Document.html(params.html);
  final list = document.querySelectorAll('p');

  maybeSplit(String text) {
    final pattern = RegExp(r'\W');
    var list = [text];

    isTooBig(String text) => text.length > params.maxParagraphSize;

    while (list.any(isTooBig)) {
      list = list
          .map((it) => isTooBig(it)
              ? it.splitEqually(
                  pattern,
                  indicator: params.splitIndicator,
                )
              : [it])
          .expand((it) => it)
          .toList();
    }

    return list;
  }

  return list
      .map((it) => it.text.trim())
      .map(maybeSplit)
      .expand((it) => it)
      .toList(growable: false);
}

/// The return type of [ExtractElementsUseCase],
/// Represents the html elements that were extracted
@immutable
class Elements {
  final ProcessHtmlResult processHtmlResult;
  final List<String> paragraphs;

  const Elements({
    required this.processHtmlResult,
    required this.paragraphs,
  });
}

@immutable
class _IsolateParams {
  final String html;
  final String splitIndicator;
  final int maxParagraphSize;

  const _IsolateParams({
    required this.html,
    required this.splitIndicator,
    required this.maxParagraphSize,
  });
}
