import 'dart:convert';

import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_readability/xayn_readability.dart';

const String kRequestMethod = 'GET';
const String kUserAgent =
    'Mozilla/5.0 (Linux; Android 8.0.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.84 Mobile Safari/537.36';

@injectable
class LoadHtmlUseCase<T> extends UseCase<Uri, Progress> {
  LoadHtmlUseCase();

  @override
  Stream<Progress> transaction(Uri param) async* {
    yield Progress.start(uri: param);

    final client = createHttpClient(userAgent: kUserAgent);
    final url = param.toString();
    final response = await client.send(http.Request(kRequestMethod, url));
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
