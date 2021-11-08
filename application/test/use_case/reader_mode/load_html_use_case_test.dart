import 'package:flutter_test/flutter_test.dart';
import 'package:http_client/http_client.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/load_html_use_case.dart';

import 'load_html_use_case_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient client;
  final uri = Uri.dataFromString('<p>hi!</p>');

  setUp(() {
    client = MockClient();

    when(client.send(any)).thenAnswer(
      (_) async => http.Response(
        200,
        '',
        http.Headers(),
        '<p>hi!</p>',
      ),
    );
  });

  group('LoadHtmlUseCase: ', () {
    useCaseTest(
      'Can log incoming events: ',
      build: () => LoadHtmlUseCase(httpClient: client),
      input: [uri],
      expect: [
        useCaseSuccess(Progress.start(uri: uri)),
        useCaseSuccess(Progress.finish(uri: uri, html: '<p>hi!</p>')),
      ],
    );
  });
}
