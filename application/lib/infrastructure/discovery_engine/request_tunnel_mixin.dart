import 'dart:convert';

import 'package:http_client/console.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:xayn_discovery_app/domain/model/document/document_vo.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/request_logger.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

final Map<Uri, String> cardOrigin = <Uri, String>{};
final Map<UniqueRequest, Future<String>> _cache =
    <UniqueRequest, Future<String>>{};

mixin RequestTunnelMixin {
  late final http.Client client = http.ConsoleClient();
  late final RequestLogger requestLogger = di.get();
  late final Uri baseUri = Uri.parse(Env.searchApiBaseUrl);
  var _lhPageCount = 0;

  Future<void> startRequestTunneling(String url) async {
    final handler = const Pipeline().addHandler(_echoRequest(Uri.parse(url)));

    await shelf_io.serve(handler, 'localhost', 1234);
  }

  Future<Response> Function(Request) _echoRequest(Uri uri) =>
      (Request request) async {
        final result = await _doRequest(uri)(request);

        return Response.ok(result);
      };

  Future<String> Function(Request) _doRequest(Uri uri) => (Request request) {
        final isLatestHeadlines = request.url.path == '_lh';

        if (isLatestHeadlines) {
          return _fetchLatestHeadlines(uri)(request);
        }

        final queryParameters =
            Map<String, String>.from(request.url.queryParameters);
        final q = queryParameters['q'] ?? '';
        final isPersonalizedSearch = q.contains(') OR (');

        if (isPersonalizedSearch) {
          return _fetchPersonalized(uri, false)(request);
        }

        return _fetchPersonalized(uri, true)(request);
      };

  Future<String> Function(Request) _fetchLatestHeadlines(Uri uri) =>
      (Request request) {
        final queryParameters =
            Map<String, String>.from(request.url.queryParameters);
        final page = _lhPageCount % 5 + 1;

        _lhPageCount++;

        queryParameters['page'] = '$page';

        final actualRequest = _buildActualRequest(
          request,
          uri,
          queryParameters,
        );

        return _performActualApiCall(
          _buildActualRequest(
            request,
            uri,
            queryParameters,
          ),
          const HtmlEscape().convert(actualRequest.uri.toString()),
          request.url.path,
        );
      };

  Future<String> Function(Request) _fetchPersonalized(
          Uri uri, bool isNormalSearch) =>
      (Request request) async {
        try {
          const decoder = JsonDecoder();
          const encoder = JsonEncoder();
          final groupMatcher = RegExp(r'\(([^\)]+)\)');
          final keywordGroups = isNormalSearch
              ? '(${request.url.queryParameters['q']})'
              : request.url.queryParameters['q']!;
          final params = Map<String, String>.from(request.url.queryParameters);

          UniqueRequest Function(String) buildActualRequest(Request request) =>
              (String keywords) {
                final mtlUri = baseUri.replace(
                  path: '_mlt',
                  queryParameters: <String, dynamic>{
                    'like': keywords,
                    'search_in': 'title_excerpt',
                    'min_term_freq': '1',
                    'page_size': '100',
                    'to_rank': params['to_rank'],
                    'lang': isNormalSearch
                        ? <String>{params['lang']!.toLowerCase(), 'en'}
                            .join(',')
                        : params['lang'],
                    'countries': isNormalSearch
                        ? <String>{
                            params['countries']!.toUpperCase(),
                            'US',
                            'GB'
                          }.join(',')
                        : params['countries'],
                    'page': params['page'],
                    'sort_by': params['sort_by'],
                    'from': '30d',
                  },
                );

                final headers = Map<String, String>.from(request.headers);

                headers['host'] = mtlUri.host;

                return UniqueRequest.fromMap(
                  request.requestedUri.queryParameters,
                  keywords: keywords,
                  request: http.Request(
                    request.method,
                    mtlUri,
                    headers: headers,
                    encoding: request.encoding,
                  ),
                );
              };

          final mapper = buildActualRequest(request);
          final keySets =
              groupMatcher.allMatches(keywordGroups).map((it) => it.group(1)!);
          final query = keySets.join(' ');
          final ncRequest = mapper(query);
          final allArticles = <DocumentVO>{};

          logger
              .i('will load from cache: ${_cache.containsKey(request)} $query');

          final body = await _cache.putIfAbsent(ncRequest, () async {
            final data = await client.send(ncRequest.request);

            return await data.readAsString();
          });
          final json = Map<String, dynamic>.from(decoder.convert(body));
          final articles = json['articles'] as List? ?? const [];
          final entries = articles
              .cast<Map<String, dynamic>>()
              .map(DocumentVO.fromJson)
              .toList(growable: false);

          for (final entry in entries) {
            cardOrigin[entry.uri] = '$query (${entry.score.floor()})';
          }

          allArticles.addAll(entries);

          final sortedArticlesByScore = allArticles.toList()
            ..removeWhere((it) => it.score < 16.0);
          final rawArticles = sortedArticlesByScore
              .map((it) => it.jsonRaw)
              .toList(growable: false);

          logger.i('fetched ${rawArticles.length} personalized articles');

          final response = <String, dynamic>{
            "status": "ok",
            "total_hits": rawArticles.length,
            "page": params['page'],
            "total_pages": 1,
            "page_size": rawArticles.length,
            "articles": rawArticles,
            "user_input": {
              "q": keywordGroups,
              "search_in": ["title_summary"],
              "lang": params['lang'],
              "not_lang": null,
              "countries": params['countries']!.split(','),
              "not_countries": null,
              "from": params['from'],
              "to": null,
              "ranked_only": "True",
              "from_rank": null,
              "to_rank": null,
              "sort_by": params['sort_by'],
              "page": params['page'],
              "size": 1,
              "sources": null,
              "not_sources": null,
              "topic": null,
              "published_date_precision": null
            }
          };

          requestLogger.addResultSet(
            ResultSet(
              timestamp: DateTime.now(),
              path: '_mlt',
              query: keySets.join(' || '),
              articles: rawArticles,
            ),
          );

          return encoder.convert(response);
        } catch (e, s) {
          logger.e('$e: $s');
        }

        return '';
      };

  /*Future<String> Function(Request) _fetchQuery(Uri uri) => (Request request) {
        final queryParameters =
            Map<String, String>.from(request.url.queryParameters);

        return _performActualApiCall(
          _buildActualRequest(
            request,
            uri,
            queryParameters,
          ),
          queryParameters['q'] ?? 'no query',
          request.url.path,
        );
      };*/

  http.Request _buildActualRequest(
      Request request, Uri uri, Map<String, dynamic> queryParameters) {
    final actualUri = request.url.replace(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      queryParameters: queryParameters,
    );
    final headers = Map<String, String>.from(request.headers);

    headers['host'] = uri.host;

    return http.Request(
      request.method,
      actualUri,
      headers: headers,
      encoding: request.encoding,
    );
  }

  Future<String> _performActualApiCall(
      http.Request request, String query, String path) async {
    final response = await client.send(request);
    final body = await response.readAsString();
    var json = const JsonDecoder().convert(body) as Map;
    final rawArticles = List.from(json['articles'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .toList(growable: false);

    requestLogger.addResultSet(ResultSet(
      timestamp: DateTime.now(),
      path: path,
      query: query,
      articles: rawArticles,
    ));

    return body;
  }
}
