import 'package:html/dom.dart' as dom;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';

@injectable
class ExtractParagraphsUseCase extends UseCase<String, List<String>> {
  @override
  Stream<List<String>> transaction(String param) async* {
    yield _extractParagraphs(param);
  }
}

/// isolate code, needs to be a standalone method
List<String> _extractParagraphs(final String contents) {
  final element = dom.DocumentFragment.html(contents);

  return element
      .querySelectorAll('h1,h2,p')
      .map((it) => it.text)
      .toList(growable: false);
}
