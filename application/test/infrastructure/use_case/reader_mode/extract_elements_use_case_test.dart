import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';
import 'package:xayn_readability/xayn_readability.dart';

import 'matchers.dart';

void main() {
  const html = '''<div id="readability-page-1">
        <section>
          <h2>This is a test!</h2>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. In at.</p>
        </section>
        <div>
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent a.</p>
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
    useCaseTest<ExtractElementsUseCase, ProcessHtmlResult, Elements>(
      'Converts into readable html: ',
      build: () => ExtractElementsUseCase(),
      input: [result],
      expect: [
        elementsSuccess(
          const Elements(
            paragraphs: [
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In at.',
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent a.',
            ],
            processHtmlResult: result,
          ),
        ),
      ],
    );
  });
}
