import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/fetcher_params.dart';

/// A [UseCase] which takes a proxy url [fetcherUrl], then appends all
/// properties from [FetcherParams] as query parameters.
@injectable
class ProxyUriUseCase extends UseCase<FetcherParams, FetcherParams> {
  /// The proxy url
  /// Example: "https://fetch.me"
  final String fetcherUrl;

  /// Creates a new proxy url use case, testing only, see [ProxyUriUseCase.fetcherUrlFromEnv],
  /// which is also the default di factory constructor.
  @visibleForTesting
  ProxyUriUseCase({required this.fetcherUrl});

  /// Creates a new proxy url use case, using [fetcherUrl] from `Env`.
  @factoryMethod
  ProxyUriUseCase.fetcherUrlFromEnv() : fetcherUrl = Env.imageFetcherUrl;

  @override
  Stream<FetcherParams> transaction(FetcherParams param) async* {
    if (param.cookies != null) {
      yield param;
    } else {
      final fetcherUri = Uri.parse(fetcherUrl);
      final queryParameters = {'url': param.uri.toString()};

      if (param.fit != null) {
        queryParameters.putIfAbsent('fit', () => param.fit.toString());
      }

      if (param.width != null) {
        queryParameters.putIfAbsent('w', () => param.width.toString());
      }

      if (param.height != null) {
        queryParameters.putIfAbsent('h', () => param.height.toString());
      }

      if (param.blur != null) {
        queryParameters.putIfAbsent('blur', () => param.blur.toString());
      }

      if (param.rotation != null) {
        queryParameters.putIfAbsent('rot', () => param.rotation.toString());
      }

      if (param.tint != null) {
        queryParameters.putIfAbsent('tint', () => param.tint.toString());
      }

      yield param.copyWith(
          uri: fetcherUri.replace(path: '/', queryParameters: queryParameters));
    }
  }
}
