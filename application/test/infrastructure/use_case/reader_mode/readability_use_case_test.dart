import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/readability_use_case.dart';
import 'package:xayn_readability/xayn_readability.dart';

import 'matchers.dart';

void main() {
  final dummyUri = Uri.dataFromString('<p>hi!</p>');
  const html = ''' 
    <html>
      <body>
        <section>
          <h1>This is a test!</h1>
          <p>1</p>
        </section>
        <div>
          <p>2</p>
          <div>
            <img src="https://www.xayn.com" />
          </div>
        </div>
      </body>
    </html>
  ''';
  const expectedHtml = '''<div id="readability-page-1">
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

  setUp(() {});

  group('ReadabilityUseCase: ', () {
    useCaseTest<ReadabilityUseCase, ReadabilityConfig, ProcessHtmlResult>(
      'Converts into readable html: ',
      build: () => ReadabilityUseCase(),
      input: [
        ReadabilityConfig(
          html: html,
          disableJsonLd: true,
          uri: dummyUri,
          classesToPreserve: const [],
        )
      ],
      expect: [
        processHtmlSuccess(
          const ProcessHtmlResult(
            contents: expectedHtml,
            themeColor: 4294967295,
            textSize: 136,
          ),
        ),
      ],
    );
  });
}
