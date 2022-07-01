import 'dart:convert';
import 'dart:developer' as dev;

import 'package:http_client/console.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:xayn_discovery_app/domain/model/document/document_vo.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

final List<ResultSet> resultSets = <ResultSet>[];
final Map<UniqueRequest, Future<http.Response>> _cache =
    <UniqueRequest, Future<http.Response>>{};

final Uri searchEndpointAlternate = Uri.parse(
    'https://c8tuq9oow3.execute-api.eu-west-1.amazonaws.com/dev/v2/search_mlt');

String reportCurrentResultSets() {
  var body = '';

  for (final resultSet in resultSets) {
    final timeStamp =
        '${resultSet.timestamp.hour}h:${resultSet.timestamp.minute}m';
    final entry =
        '<p><b>${resultSet.path}: $timeStamp</b>&nbsp;<i>${resultSet.articles.length} results received</i><br>${resultSet.query}</p>';
    var listing = '<ol>';

    if (resultSet.path != '_lh') {
      var res = resultSet.articles;
      final actualLen = res.length;

      for (final article in res) {
        listing =
            '$listing<li>${article['published_date']}:&nbsp;<a href="${article['link']}">${const HtmlEscape().convert(article['title'])}</a>&nbsp;[${article['_score']}]</li>';
      }

      listing =
          '<span>Displaying top ${res.length} of $actualLen results: </span>$listing';
    }

    listing = '$listing</ol>';

    body = '$body$entry$listing';
  }

  dev.log('<html><body>$body</body></html>');

  return '<html><body>$body</body></html>';
}

mixin RequestTunnelMixin {
  late final client = http.ConsoleClient();
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
          return _fetchPersonalized(uri)(request);
        }

        return _fetchQuery(uri)(request);
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

  Future<String> Function(Request) _fetchPersonalized(Uri uri) =>
      (Request request) async {
        const decoder = JsonDecoder();
        const encoder = JsonEncoder();
        final groupMatcher = RegExp(r'\(([^\)]+)\)');
        final keywordGroups = request.url.queryParameters['q']!;
        final params = Map<String, String>.from(request.url.queryParameters);

        UniqueRequest Function(String) buildActualRequest(Request request) =>
            (String keywords) {
              final mtlUri = searchEndpointAlternate.replace(
                queryParameters: <String, dynamic>{
                  'like': keywords,
                  'search_in': 'title_excerpt',
                  'min_term_freq': '1',
                  'page_size': '34',
                  'to_rank': params['to_rank'],
                  'lang': params['lang'],
                  'countries': params['countries'],
                  'page': params['page'],
                  'sort_by': params['sort_by'],
                  'from': params['from'],
                },
              );
              final headers = Map<String, String>.from(request.headers)
                ..remove('authorization');

              headers['host'] = mtlUri.host;
              headers['x-api-key'] = Env.searchApiSecretKeyAlternate;

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
        final requests = keySets.map(mapper).toList(growable: false);
        final allArticles = <DocumentVO>{};

        for (final request in requests) {
          logger.i(
              'will load from cache: ${_cache.containsKey(request)} ${request.keywords}');

          final r = await _cache.putIfAbsent(
              request, () => client.send(request.request));
          final body = await r.readAsString();
          final json = Map<String, dynamic>.from(decoder.convert(body));
          final articles = json['articles'] as List;

          try {
            allArticles.addAll(
                articles.cast<Map<String, dynamic>>().map(DocumentVO.fromJson));
          } catch (e, s) {
            logger.e('e: $e\n$s');
          }
        }

        var sortedArticlesByScore = allArticles.toList()
          /*..removeWhere((it) => it.score < 14.5)*/
          ..sort();

        if (sortedArticlesByScore.length > 100) {
          sortedArticlesByScore = sortedArticlesByScore.sublist(0, 100);
        }

        final rawArticles = sortedArticlesByScore
            .map((it) => it.jsonRaw)
            .toList(growable: false);

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

        resultSets.add(
          ResultSet(
            timestamp: DateTime.now(),
            path: '_mlt',
            query: keySets.join(' || '),
            articles: rawArticles,
          ),
        );

        return encoder.convert(response);
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
    final response = await client.send(request);
    final body = await response.readAsString();
    var json = const JsonDecoder().convert(body) as Map;
    final rawArticles = List.from(json['articles'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .toList(growable: false);

    resultSets.add(ResultSet(
      timestamp: DateTime.now(),
      path: path,
      query: query,
      articles: rawArticles,
    ));

    return body;
  }
}

class ResultSet {
  final DateTime timestamp;
  final String path;
  final String query;
  final List<Map<String, dynamic>> articles;

  const ResultSet({
    required this.timestamp,
    required this.path,
    required this.query,
    required this.articles,
  });
}

class UniqueRequest {
  final http.Request request;
  final String lang;
  final List<String> countries;
  final int toRank;
  final int pageSize;
  final int page;
  final String sortBy;
  final String from;
  final String keywords;
  final int _hashCode;

  @override
  bool operator ==(Object other) {
    if (other is UniqueRequest) return hashCode == other.hashCode;

    return false;
  }

  @override
  int get hashCode => _hashCode;

  UniqueRequest.fromMap(
    Map<String, String> data, {
    required this.keywords,
    required this.request,
  })  : lang = data['lang']!,
        countries = data['countries']!.split(','),
        toRank = int.parse(data['to_rank']!),
        pageSize = int.parse(data['page_size']!),
        page = int.parse(data['page']!),
        sortBy = data['sort_by']!,
        from = data['from']!,
        _hashCode = Object.hashAll([
          keywords,
          data['lang'],
          data['countries'],
          data['page'],
        ]);
}
