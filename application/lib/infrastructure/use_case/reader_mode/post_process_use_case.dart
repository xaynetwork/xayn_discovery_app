import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_readability/xayn_readability.dart';

@injectable
class PostProcessUseCase extends UseCase<ProcessHtmlResult, Uri> {
  @override
  Stream<Uri> transaction(ProcessHtmlResult param) async* {
    final contents = param.contents;

    if (contents != null) {
      yield Uri.dataFromBytes(
        const Utf8Encoder().convert(
          await compute(_processHtml, contents),
        ),
      );
    }
  }
}

String _processHtml(final String html) {
  final document = dom.Document.html(html);

  return document.outerHtml;
}
