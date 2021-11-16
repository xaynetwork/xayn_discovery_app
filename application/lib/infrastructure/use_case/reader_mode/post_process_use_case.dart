import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_readability/xayn_readability.dart';

@injectable
class PostProcessUseCase extends UseCase<CardData, ProcessHtmlResult> {
  @override
  Stream<ProcessHtmlResult> transaction(CardData param) async* {
    final html = await compute(_processHtml, param);

    yield param.processHtmlResult.withOtherContent(html);
  }
}

String _processHtml(final CardData cardData) {
  final document = dom.Document.html(cardData.processHtmlResult.contents!);
  final images = document.querySelectorAll('img');
  final nodes = document.querySelectorAll('');

  images.where((it) {
    final src = it.attributes['src'];

    if (src != null) {
      final uri = Uri.parse(src);

      if (uri == cardData.imageUri) return true;
    }

    return false;
  }).forEach((it) => it.remove());

  nodes
      .where((it) =>
          it.text.trim() == cardData.title || it.text == cardData.snippet)
      .forEach((it) => it.remove());

  return document.outerHtml;
}

class CardData {
  final String title;
  final String snippet;
  final Uri imageUri;
  final ProcessHtmlResult processHtmlResult;

  const CardData({
    required this.title,
    required this.snippet,
    required this.imageUri,
    required this.processHtmlResult,
  });
}
