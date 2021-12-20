import 'package:flutter/foundation.dart';
import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/http_requests/common_params.dart';
import 'package:xayn_discovery_app/infrastructure/request_client/client.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/fetcher_params.dart';

@injectable
class ResolveRedirectsUseCase extends UseCase<FetcherParams, FetcherParams> {
  final Client client;
  final Map<String, String> headers;

  @visibleForTesting
  ResolveRedirectsUseCase({
    required this.client,
    required this.headers,
  });

  @factoryMethod
  ResolveRedirectsUseCase.standard({required this.client})
      : headers = CommonHttpRequestParams.httpRequestHeaders;

  @override
  Stream<FetcherParams> transaction(FetcherParams param) async* {
    final url = param.uri.toString();
    final response = await client.send(
      http.Request(
        CommonHttpRequestParams.httpRequestOptions,
        url,
        followRedirects: false,
        headers: headers,
        timeout: CommonHttpRequestParams.httpRequestTimeout,
      ),
    );

    if (response.statusCode == 302 &&
        response.headers.containsKey('set-cookie')) {
      yield param.copyWith(canUseProxy: false);
    } else {
      yield param;
    }
  }
}
