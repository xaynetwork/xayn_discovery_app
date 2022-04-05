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
        encoding: utf8,
        headers: headers,
        timeout: CommonHttpRequestParams.httpRequestTimeout,
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      yield Progress.finish(html: '', uri: param);
    } else {
      yield Progress.finish(
        html: _extractResponseBody(await response.readAsBytes()),
        uri: param,
      );
    }
  }

  String _extractResponseBody(List<int> bytes) {
    try {
      // we did a request for utf-8...
      const decoder = Utf8Codec();

      return decoder.decode(bytes);
    } catch (e) {
      // ...unfortunately some sites still then return eg iso-8859-1
      const decoder = Latin1Codec();

      return decoder.decode(bytes);
    }
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
