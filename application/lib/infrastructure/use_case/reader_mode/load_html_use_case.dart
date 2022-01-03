import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/http_requests/common_params.dart';
import 'package:xayn_discovery_app/infrastructure/request_client/client.dart';

/// A [UseCase] which uses a Platform-specific client to fetch the html
/// contents at the Uri that was provided as input.
///
/// This [UseCase] emits both a start and finish [Progress].
@injectable
class LoadHtmlUseCase extends UseCase<Uri, Progress> {
  final Client client;
  final Map<String, String> headers;

  @visibleForTesting
  LoadHtmlUseCase({
    required this.client,
    required this.headers,
  });

  @factoryMethod
  LoadHtmlUseCase.standard({required this.client})
      : headers = CommonHttpRequestParams.httpRequestHeaders;

  @override
  Stream<Progress> transaction(Uri param) async* {
    yield Progress.start(uri: param);

    final url = param.toString();
    final response = await client.sendWithRedirectGuard(
      http.Request(
        CommonHttpRequestParams.httpRequestGet,
        url,
        followRedirects: false,
        headers: headers,
        timeout: CommonHttpRequestParams.httpRequestTimeout,
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
          'response status code: ${response.statusCode}: ${response.reasonPhrase}');
    }

    final body = _extractResponseBody(await response.readAsBytes());

    yield Progress.finish(
      html: body,
      uri: param,
    );
  }

  String _extractResponseBody(Object body) {
    if (body is String) {
      return body;
    } else if (body is List<int>) {
      // do allow malformed here, as some sites may have encoding errors,
      // but we still want to get their response in.
      const decoder = Utf8Codec(allowMalformed: true);

      return decoder.decode(body);
    }

    throw StateError(
        'body is neither String or List<int>, unable to decode into String');
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
