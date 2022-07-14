import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http_client/console.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:xayn_discovery_app/domain/model/document/document_vo.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/request_logger.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

final Map<Uri, String> cardOrigin = <Uri, String>{};
final Set<String> likedDocuments = <String>{};
final Map<Uri, String> uriMapper = <Uri, String>{};
final Map<Uri, Future<String>> _pendingRequests = <Uri, Future<String>>{};

void likeDocument(Uri uri) {
  final id = uriMapper[uri];

  if (id != null) {
    likedDocuments.add(id);
  }
}

mixin RequestTunnelMixin {
  late final ConnectivityObserver observer = di.get<ConnectivityObserver>();
  late final http.Client client = http.ConsoleClient();
  late final RequestLogger requestLogger = di.get();
  late final Uri baseUri = Uri.parse(Env.searchApiBaseUrl);

  Future<void> startRequestTunneling(String url) async {
    final handler = const Pipeline().addHandler(_echoRequest(Uri.parse(url)));

    await shelf_io.serve(handler, 'localhost', 1234);
  }

  Future<Response> Function(Request) _echoRequest(Uri uri) =>
      (Request request) async {
        logger.i('checking connection...');

        final cr = await observer.isUp().timeout(const Duration(seconds: 20),
            onTimeout: () => ConnectivityResult.none);

        if (cr == ConnectivityResult.none) {
          logger.i('connection is down');
          return Response.internalServerError();
        }

        logger.i('connection is up');

        final req = _pendingRequests.putIfAbsent(
            request.url, () => _doRequest(uri)(request));
        final result = await req;

        _pendingRequests.remove(request.url);

        return Response.ok(result);
      };

  Future<String> Function(Request) _doRequest(Uri uri) => (Request request) {
        final isLatestHeadlines = request.url.path == '_lh';

        logger.i('fetching ${request.url}');

        if (isLatestHeadlines) {
          return _fetchLatestHeadlines(uri)(request);
        }

        final queryParameters =
            Map<String, String>.from(request.url.queryParameters);
        final q = queryParameters['q'] ?? '';
        final isPersonalizedSearch = q.contains(') OR (');

        if (isPersonalizedSearch) {
          return _fetchPersonalized(uri)(request);
        }

        return _fetchQuery(uri)(request);
      };

  Future<String> Function(Request) _fetchLatestHeadlines(Uri uri) =>
      (Request request) {
        final queryParameters =
            Map<String, String>.from(request.url.queryParameters);

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

  Future<String> Function(Request) _fetchPersonalized(Uri uri) =>
      (Request request) async {
        try {
          final random = Random();
          const decoder = JsonDecoder();
          const encoder = JsonEncoder();
          final params = Map<String, String>.from(request.url.queryParameters);
          final rndList = likedDocuments.toList()
            ..sort((a, b) => random.nextInt(3) - 1);
          final cnt = min(rndList.length, 3);
          final ids = rndList.take(cnt);

          logger.i('getting from $ids');

          buildActualRequest(Request request) {
            final mtlUri = baseUri.replace(
              path: '_mlt',
              queryParameters: <String, dynamic>{
                'ids': ids.join(','),
                'search_in': 'title_excerpt',
                'min_term_freq': '1',
                'page_size': '100',
                'to_rank': params['to_rank'],
                'lang': params['lang'],
                'countries': params['countries'],
                'page': params['page'],
                'sort_by': params['sort_by'],
                'from': '30d',
              },
            );

            final headers = Map<String, String>.from(request.headers);

            headers['host'] = mtlUri.host;

            return UniqueRequest.fromMap(
              request.requestedUri.queryParameters,
              keywords: ids.join(','),
              request: http.Request(
                request.method,
                mtlUri,
                headers: headers,
                encoding: request.encoding,
              ),
            );
          }

          final ncRequest = buildActualRequest(request);
          final allArticles = <DocumentVO>{};

          final data = await client.send(ncRequest.request);
          final body = await data.readAsString();
          final json = Map<String, dynamic>.from(decoder.convert(body));
          final articles = json['articles'] as List? ?? const [];
          final entries = articles
              .cast<Map<String, dynamic>>()
              .map(DocumentVO.fromJson)
              .toList(growable: false);

          for (final entry in entries) {
            cardOrigin[entry.uri] = '$ids (${entry.score.floor()})';
            uriMapper[entry.uri] = entry.id;
          }

          allArticles.addAll(entries);

          final rawArticles =
              allArticles.map((it) => it.jsonRaw).toList(growable: false);

          logger.i('fetched ${rawArticles.length} personalized articles');

          final response = <String, dynamic>{
            "status": "ok",
            "total_hits": rawArticles.length,
            "page": params['page'],
            "total_pages": 1,
            "page_size": rawArticles.length,
            "articles": rawArticles,
            "user_input": {
              "q": ids.join(','),
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
              query: ids.join(','),
              articles: rawArticles,
            ),
          );

          return encoder.convert(response);
        } catch (e, s) {
          logger.e('$e: $s');
        }

        return '';
      };

  Future<String> Function(Request) _fetchQuery(Uri uri) => (Request request) {
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
      };

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
    logger.i('make call');
    final response = await client.send(request);
    logger.i('success!');
    final body = await response.readAsString();
    var json = const JsonDecoder().convert(body) as Map;
    final rawArticles = List.from(json['articles'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .toList(growable: false);

    try {
      for (final article in rawArticles) {
        if (article.containsKey('link') && article.containsKey('_id')) {
          uriMapper[Uri.parse(article['link'])] = article['_id'];
        } else {
          logger
              .i('bad article link: ${article['link']}, id: ${article['_id']}');
        }
      }
    } catch (e, s) {
      logger.e('$e $s');
    }

    requestLogger.addResultSet(ResultSet(
      timestamp: DateTime.now(),
      path: path,
      query: query,
      articles: rawArticles,
    ));

    return body;
  }
}
