import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/http_requests/common_params.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/cache_manager_event.dart';
import 'package:xayn_discovery_app/infrastructure/request_client/client.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/fetcher_params.dart';

/// A use case which calls an endpoint directly,
/// as opposed to calling it via a proxy, such as the image fetcher for example.
@injectable
class DirectUriUseCase extends UseCase<FetcherParams, CacheManagerEvent> {
  final Client client;
  final Map<String, String> headers;

  @visibleForTesting
  DirectUriUseCase({
    required this.client,
    required this.headers,
  });

  @factoryMethod
  DirectUriUseCase.standard({required this.client})
      : headers = CommonHttpRequestParams.httpRequestHeaders;

  @override
  Stream<CacheManagerEvent> transaction(FetcherParams param) async* {
    final url = param.uri.toString();
    final response = await client.sendWithRedirectGuard(
      http.Request(
        CommonHttpRequestParams.httpRequestGet,
        url,
        followRedirects: false,
        headers: headers,
        timeout: CommonHttpRequestParams.httpRequestTimeout,
      ),
    );

    yield CacheManagerEvent.completed(
      param.uri,
      Uint8List.fromList(
        await response.readAsBytes(),
      ),
    );
  }
}
