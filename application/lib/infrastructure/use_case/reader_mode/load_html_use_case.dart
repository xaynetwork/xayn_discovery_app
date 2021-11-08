import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_readability/xayn_readability.dart';

part 'load_html_use_case.freezed.dart';

const String kRequestMethod = 'GET';
const String kUserAgent =
    'Mozilla/5.0 (Linux; Android 8.0.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.84 Mobile Safari/537.36';

/// A [UseCase] which uses a Platform-specific client to fetch the html
/// contents at the Uri that was provided as input.
///
/// This [UseCase] emits both a start and finish [Progress].
@injectable
class LoadHtmlUseCase<T> extends UseCase<Uri, Progress> {
  http.Client? httpClient;

  LoadHtmlUseCase({this.httpClient});

  @override
  Stream<Progress> transaction(Uri param) async* {
    yield Progress.start(uri: param);

    final client = httpClient ?? createHttpClient(userAgent: kUserAgent);
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

/// The progress status of the html fetch.
/// When finished, [html] is filled.
/// [isCompleted] is true when finished, false when started.
/// [uri] is the Uri that is being fetched.
@freezed
class Progress with _$Progress {
  const Progress._();

  const factory Progress({
    required String html,
    required Uri uri,
    required bool isCompleted,
  }) = _Progress;

  factory Progress.start({required Uri uri}) =>
      Progress(uri: uri, html: '', isCompleted: false);

  factory Progress.finish({
    required Uri uri,
    required String html,
  }) =>
      Progress(uri: uri, html: '', isCompleted: true);
}
