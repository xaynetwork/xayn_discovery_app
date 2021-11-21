import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_readability/xayn_readability.dart';

@injectable
class PostProcessUseCase extends UseCase<CardData, Uri> {
  @override
  Stream<Uri> transaction(CardData param) async* {
    final html = await compute(_processHtml, param);
    const encoder = Utf8Encoder();

    yield Uri.dataFromBytes(encoder.convert(html));
  }
}

String _processHtml(final CardData cardData) {
  final document = dom.Document.html(cardData.processHtmlResult.contents!);

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
