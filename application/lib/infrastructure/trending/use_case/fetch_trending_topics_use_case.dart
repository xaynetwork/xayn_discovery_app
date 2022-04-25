import 'dart:convert';

import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/http_requests/common_params.dart';
import 'package:xayn_discovery_app/domain/model/trending_topics/topic.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_local_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/request_client/client.dart';

const String _kUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36';
const String _kEndpoint =
    'https://api.bing.microsoft.com/v7.0/news/trendingtopics';
const Map<String, String> _kHeaders = <String, String>{
  'Ocp-Apim-Subscription-Key': Env.trendingTopicsApiKey,
  'User-Agent': _kUserAgent,
};

@injectable
class FetchTrendingTopicsUseCase extends UseCase<None, Set<Topic>> {
  final Client client;
  final GetLocalMarketsUseCase getLocalMarketsUseCase;

  FetchTrendingTopicsUseCase(
    this.client,
    this.getLocalMarketsUseCase,
  );

  @override
  Stream<Set<Topic>> transaction(None param) async* {
    final markets = await getLocalMarketsUseCase.singleOutput(none);
    final singleMarket = markets.first;
    final mkt =
        '${singleMarket.langCode.toLowerCase()}-${singleMarket.countryCode.toUpperCase()}';
    final response = await client.send(
      http.Request(
        CommonHttpRequestParams.httpRequestGet,
        Uri.parse(_kEndpoint).replace(queryParameters: {'mkt': mkt}),
        headers: {
          ..._kHeaders,
          'mkt':
              '${singleMarket.langCode.toLowerCase()}-${singleMarket.countryCode.toUpperCase()}'
        },
        timeout: CommonHttpRequestParams.httpRequestTimeout,
      ),
    );
    final data = await response.readAsString();
    final json = const JsonDecoder().convert(data) as Map;
    final topicsRaw = json['value'] as List;

    yield {...topicsRaw.cast<Map>().map(_toTopic)};
  }

  Topic _toTopic(Map json) => Topic(
        name: json['name'],
        image: Uri.parse(json['image']['url']),
        query: json['query']['text'],
      );
}
