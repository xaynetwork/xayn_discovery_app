import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_readability/xayn_readability.dart';

@injectable
class ExtractElementsUseCase<T> extends UseCase<ProcessHtmlResult, Elements> {
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

_ProcessHtmlResult _processHtml(final String html) {
  final document = dom.Document.html(html);
  final article = document.querySelector('[id="readability-page-1"]');
  final list = article?.children.first.children ?? const [];

  return _ProcessHtmlResult(
    paragraphs: list
        .map((it) => it.outerHtml)
        .where((it) => it.length >= 10)
        .toList(growable: false),
    images: document
        .querySelectorAll('img')
        .where((it) => it.attributes.containsKey('src'))
        .map((it) => it.attributes['src'] as String)
        .toList(growable: false),
  );
}

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

class _ProcessHtmlResult {
  final List<String> paragraphs;
  final List<String> images;

  const _ProcessHtmlResult({
    required this.paragraphs,
    required this.images,
  });
}
