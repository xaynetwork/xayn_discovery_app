import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/http_requests/common_params.dart';
import 'package:xayn_discovery_app/infrastructure/request_client/client.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';

/// Amount of days that downloaded html remains stored
/// If it is evicted from the cache, the user just needs to re-fetch the html,
/// which will create another 7 day entry
const Duration _kCacheDuration = Duration(days: 7);

/// A [UseCase] which uses a Platform-specific client to fetch the html
/// contents at the Uri that was provided as input.
///
/// This [UseCase] emits both a start and finish [Progress].
@injectable
class LoadHtmlUseCase extends UseCase<Uri, Progress> {
  final Client client;
  final ImageCacheManager cacheManager;
  final ConnectivityObserver connectivityObserver;
  final Map<String, String> headers;

  @visibleForTesting
  LoadHtmlUseCase({
    required this.client,
    required this.cacheManager,
    required this.connectivityObserver,
    required this.headers,
  });

  @factoryMethod
  LoadHtmlUseCase.standard({
    required this.client,
    required this.cacheManager,
    required this.connectivityObserver,
  }) : headers = CommonHttpRequestParams.httpRequestHeaders;

  @override
  Stream<Progress> transaction(Uri param) async* {
    yield Progress.start(uri: param);

    final url = param.toString();

    final existingData = await cacheManager.getFileFromCache(url);

    if (existingData != null) {
      final data = await existingData.file.readAsString();

      yield Progress.finish(
        html: data,
        uri: param,
      );
    } else {
      await connectivityObserver.isUp();

      final response = await client.send(
        http.Request(
          CommonHttpRequestParams.httpRequestGet,
          url,
          followRedirects: false,
          encoding: utf8,
          headers: headers,
          timeout: CommonHttpRequestParams.httpRequestTimeout,
        ),
      );

      late final String html;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        html = '';
      } else {
        html = _extractResponseBody(await response.readAsBytes());
      }

      yield Progress.finish(html: html, uri: param);

      cacheManager.putFile(
        url,
        const Utf8Encoder().convert(html),
        maxAge: _kCacheDuration,
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
