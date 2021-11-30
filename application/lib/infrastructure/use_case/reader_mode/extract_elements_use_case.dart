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
      paragraphs: result ?? const [],
    );
  }
}

/// Standalone Function which can be used as a target for [compute].
List<String> _processHtml(final String html) {
  final document = dom.Document.html(html);
  final list = document.querySelectorAll('p');

  return list
      .map((it) => it.text.trim())
      // naive heuristic filtering,
      // todo: we will need to combine a heuristic approach with an NPL approach
      .where((it) => it.length > 20)
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
