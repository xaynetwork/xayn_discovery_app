import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as dom;
import 'package:http_client/http_client.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/request_client/client.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/load_html_use_case.dart';

import '../../test_utils/utils.dart';
import 'matchers.dart';

void main() {
  late MockClient client = MockClient();
  final uri = Uri.dataFromString('<p>hi!</p>');
  final yahooWebLink = Uri.parse(
      'https://finance.yahoo.com/news/mike-morales-joins-vector-laboratories-110000153.html');

  /// these are the "old" headers, see [LoadHtmlUseCase.kHeaders] for the newest ones
  const basicHeaders = {
    'accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'accept-encoding': 'gzip, deflate, br',
    'cache-control': 'no-cache',
    'pragma': 'no-cache',
    'upgrade-insecure-requests': '1',
  };

  /// this String is the first line returned from "captcha" responses
  const captchaResponseSignature =
      'Yahoo is part of the Yahoo family of brands.';

  setUp(() {
    when(client.sendWithRedirectGuard(any)).thenAnswer(
      (_) async => http.Response(
        200,
        '',
        http.Headers(),
        '<p>hi!</p>',
      ),
    );
  });

  group('LoadHtmlUseCase: ', () {
    useCaseTest<LoadHtmlUseCase, Uri, Progress>(
      'Loads website data: ',
      build: () => LoadHtmlUseCase.standard(
        client: client,
      ),
      input: [uri],
      expect: [
        progressSuccess(Progress.start(uri: uri)),
        progressSuccess(Progress.finish(uri: uri, html: '<p>hi!</p>')),
      ],
    );
  });

  group(
    'Headers test (does not run on the CI!): ',
    () {
      useCaseTest<LoadHtmlUseCase, Uri, Progress>(
        'Loads Yahoo data: ',
        build: () => LoadHtmlUseCase.standard(
          client: Client(),
        ),
        input: [yahooWebLink],
        expect: [
          progressSuccess(Progress.start(uri: yahooWebLink)),
          testHtmlSuccess(Progress.finish(uri: yahooWebLink, html: ''),
              (String html) {
            final doc = dom.Document.html(html);
            final paragraphs = doc.querySelectorAll('p');
            final list = paragraphs.map((it) => it.text).join(', ');
            // we do not expect a captcha response
            return !list.contains(captchaResponseSignature);
          }),
        ],
      );

      useCaseTest<LoadHtmlUseCase, Uri, Progress>(
        'Fails to load Yahoo data with basic headers: ',
        build: () => LoadHtmlUseCase(
          client: Client(),
          headers: basicHeaders,
        ),
        input: [yahooWebLink],
        expect: [
          progressSuccess(Progress.start(uri: yahooWebLink)),
          testHtmlSuccess(Progress.finish(uri: yahooWebLink, html: ''),
              (String html) {
            final doc = dom.Document.html(html);
            final paragraphs = doc.querySelectorAll('p');
            final list = paragraphs.map((it) => it.text).join(', ');
            // we do expect a captcha response
            return list.contains(captchaResponseSignature);
          }),
        ],
      );
    },
    skip: true,
  );
}
