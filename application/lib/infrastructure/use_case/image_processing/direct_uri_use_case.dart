import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/http_requests/common_params.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/cache_manager_event.dart';
import 'package:xayn_discovery_app/infrastructure/request_client/client.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';

/// A use case which calls an endpoint directly,
/// as opposed to calling it via a proxy, such as the image fetcher for example.
@injectable
class DirectUriUseCase extends UseCase<Uri, CacheManagerEvent> {
  final Client client;
  final Map<String, String> headers;
  final ImageCacheManager cacheManager;
  final ConnectivityObserver connectivityObserver;

  @visibleForTesting
  DirectUriUseCase({
    required this.client,
    required this.headers,
    required this.cacheManager,
    required this.connectivityObserver,
  });

  @factoryMethod
  DirectUriUseCase.standard({
    required this.client,
    required this.cacheManager,
    required this.connectivityObserver,
  }) : headers = CommonHttpRequestParams.httpRequestHeaders;

  @override
  Stream<CacheManagerEvent> transaction(Uri param) async* {
    if (param.scheme == 'data') {
      yield CacheManagerEvent.completed(
        param,
        UriData.fromUri(param).contentAsBytes(),
      );

      return;
    }

    if (param == Uri.base) {
      // there is no image in this case
      yield CacheManagerEvent.completed(param, null);

      return;
    }

    final url = param.toString();
    final cachedVersion = await cacheManager.getFileFromCache(url);

    yield CacheManagerEvent.progress(param, .0);

    if (cachedVersion != null) {
      yield CacheManagerEvent.completed(
        param,
        await cachedVersion.file.readAsBytes(),
      );
    } else {
      observeConnectivity() async* {
        yield await connectivityObserver.checkConnectivity();
        yield* connectivityObserver.onConnectivityChanged;
      }

      await observeConnectivity()
          .firstWhere((it) => it != ConnectivityResult.none);

      final response = await client.sendWithRedirectGuard(
        http.Request(
          CommonHttpRequestParams.httpRequestGet,
          url,
          followRedirects: false,
          headers: headers,
          timeout: CommonHttpRequestParams.httpRequestTimeout,
        ),
      );

      final bytes = Uint8List.fromList(
        await response.readAsBytes(),
      );

      await cacheManager.putFile(url, bytes);

      yield CacheManagerEvent.completed(param, bytes);
    }
  }
}
