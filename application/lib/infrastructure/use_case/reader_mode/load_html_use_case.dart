import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_readability/xayn_readability.dart';

const String kRequestMethod = 'GET';
const String kUserAgent =
    'Mozilla/5.0 (Linux; Android 8.0.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.84 Mobile Safari/537.36';
const Map<String, String> kHeaders = {
  'accept': '*/*',
  'accept-encoding': 'gzip, deflate, br',
  'accept-language': 'en-GB,en;q=0.9,en-US;q=0.8,nl;q=0.7',
  'cache-control': 'no-cache',
  'pragma': 'no-cache',
  'upgrade-insecure-requests': '1',
  'sec-ch-ua':
      '" Not A;Brand";v="99", "Chromium";v="96", "Google Chrome";v="96"',
  'sec-ch-ua-mobile': '?0',
  'sec-ch-ua-platform': 'Windows',
  'sec-fetch-dest': 'empty',
  'sec-fetch-mode': 'cors',
  'sec-fetch-site': 'cross-site',
};
const Duration kTimeout = Duration(seconds: 8);
const int kMaxRedirects = 5;

/// A [UseCase] which uses a Platform-specific client to fetch the html
/// contents at the Uri that was provided as input.
///
/// This [UseCase] emits both a start and finish [Progress].
@injectable
class LoadHtmlUseCase extends UseCase<Uri, Progress> {
  final Client client;

  LoadHtmlUseCase({required this.client});

  @override
  Stream<Progress> transaction(Uri param) async* {
    yield Progress.start(uri: param);

    final url = param.toString();
    final response = await client.send(
      http.Request(
        kRequestMethod,
        url,
        followRedirects: true,
        maxRedirects: kMaxRedirects,
        headers: kHeaders,
        timeout: kTimeout,
      ),
    );
    final body = await _extractResponseBody(response);

    yield Progress.finish(html: body, uri: param);
  }

  Future<String> _extractResponseBody(http.Response response) async {
    if (response.body is String) {
      return response.body as String;
    }

    writeToBuffer(StringBuffer buffer, String part) => buffer..write(part);

    final buffer = await response.bodyAsStream!
        .transform(const Utf8Decoder())
        .fold(StringBuffer(), writeToBuffer);

    return buffer.toString();
  }
}

/// The progress status of the html fetch.
/// When finished, [html] is filled.
/// [isCompleted] is true when finished, false when started.
/// [uri] is the Uri that is being fetched.
@immutable
class Progress {
  final String html;
  final Uri uri;
  final bool isCompleted;

  const Progress.start({required this.uri})
      : html = '',
        isCompleted = false;

  const Progress.finish({
    required this.uri,
    required this.html,
  }) : isCompleted = true;
}

@injectable
class Client implements http.Client {
  final http.Client _client;

  Client() : _client = createHttpClient(userAgent: kUserAgent);

  @override
  Future close({bool force = false}) => _client.close(force: force);

  @override
  Future<http.Response> send(http.Request request) => _client.send(request);
}
