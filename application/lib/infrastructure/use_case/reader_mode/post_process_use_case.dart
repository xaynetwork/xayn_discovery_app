import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_readability/xayn_readability.dart';

@injectable
class PostProcessUseCase extends UseCase<PostProcessInput, Uri> {
  @override
  Stream<Uri> transaction(PostProcessInput param) async* {
    final contents = param.result.contents;

    if (contents != null) {
      yield Uri.dataFromBytes(
        const Utf8Encoder().convert(
          await compute(_processHtml(param.title), contents),
        ),
      );
    }
  }
}

String Function(String) _processHtml(final String title) =>
    (final String html) {
      final titleLc = title.toLowerCase();
      final document = dom.Document.html(html);
      final everything = document.querySelectorAll('*');
      final match =
          everything.firstWhereOrNull((it) => it.text.toLowerCase() == titleLc);

      if (match != null) {
        match.remove();
      }

      return document.outerHtml;
    };

class PostProcessInput {
  final ProcessHtmlResult result;
  final String title;

  const PostProcessInput({
    required this.result,
    required this.title,
  });
}
