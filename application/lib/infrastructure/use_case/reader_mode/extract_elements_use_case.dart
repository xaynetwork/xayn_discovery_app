import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_readability/xayn_readability.dart';

/// A [UseCase] which extracts any html elements as a List,
/// so that they can be loaded sequentially, as opposed to as an html tree.
@injectable
class ExtractElementsUseCase extends UseCase<ProcessHtmlResult, Elements> {
  ExtractElementsUseCase();

  @override
  Stream<Elements> transaction(ProcessHtmlResult param) async* {
    final html = param.contents;
    final result = html != null ? await compute(_processHtml, html) : null;

    yield Elements(
      processHtmlResult: param,
      paragraphs: result?.paragraphs ?? const [],
      images: result?.images ?? const [],
    );
  }
}

/// Standalone Function which can be used as a target for [compute].
_ProcessHtmlResult _processHtml(final String html) {
  final document = dom.Document.html(html);
  final list = document.querySelectorAll('p');

  return _ProcessHtmlResult(
    paragraphs: list
        .where((it) => it.text.isNotEmpty)
        .map((it) => it.outerHtml)
        .toList(growable: false),
    images: document
        .querySelectorAll('img')
        .where((it) => it.attributes.containsKey('src'))
        .map((it) => it.attributes['src'] as String)
        .toList(growable: false),
  );
}

/// The return type of [ExtractElementsUseCase],
/// Represents the html elements that were extracted
@immutable
class Elements {
  final ProcessHtmlResult processHtmlResult;
  final List<String> paragraphs;
  final List<String> images;

  const Elements({
    required this.processHtmlResult,
    required this.paragraphs,
    required this.images,
  });
}

@immutable
class _ProcessHtmlResult {
  final List<String> paragraphs;
  final List<String> images;

  const _ProcessHtmlResult({
    required this.paragraphs,
    required this.images,
  });
}
