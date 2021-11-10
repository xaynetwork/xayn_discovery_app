import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';
import 'package:xayn_readability/xayn_readability.dart';

import 'matchers.dart';

void main() {
  const html = '''<div id="readability-page-1">
        <section>
          <h2>This is a test!</h2>
          <p>1</p>
        </section>
        <div>
          <p>2</p>
          <div>
            <img src="https://www.xayn.com">
          </div>
        </div>
      
    
  </div>''';
  const result = ProcessHtmlResult(
    contents: html,
    themeColor: 4294967295,
    textSize: 136,
  );

  group('ReadabilityUseCase: ', () {
    useCaseTest(
      'Converts into readable html: ',
      build: () => ExtractElementsUseCase(),
      input: [result],
      expect: [
        elementsSuccess(
          const Elements(
            paragraphs: ['<p>1</p>', '<p>2</p>'],
            images: ['https://www.xayn.com'],
            processHtmlResult: result,
          ),
        ),
      ],
    );
  });
}
