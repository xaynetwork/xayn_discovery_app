import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:http_client/console.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

final List<ResultSet> resultSets = <ResultSet>[];

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
        final groupMatcher = RegExp(r'\(([^\)]+)\)');
        final keywordGroups = request.url.queryParameters['q']!;

        http.Request Function(String) buildActualRequest(Request request) =>
            (String keywords) {
              final mtlUri = searchEndpointAlternate.replace(
                queryParameters: <String, dynamic>{
                  'like': keywords,
                  'search_in': 'title_excerpt',
                  'min_term_freq': '1',
                  'page_size': '34',
                  'to_rank': '9000',
                },
              );
              final headers = Map<String, String>.from(request.headers)
                ..remove('authorization');

              headers['host'] = mtlUri.host;
              headers['x-api-key'] = Env.searchApiSecretKeyAlternate;

              return http.Request(
                request.method,
                mtlUri,
                headers: headers,
                encoding: request.encoding,
              );
            };

        final mapper = buildActualRequest(request);
        final keySets =
            groupMatcher.allMatches(keywordGroups).map((it) => it.group(1)!);
        final requests = keySets.map(mapper).toList(growable: false);
        final allArticles = HashSet<Map<String, dynamic>>(
          equals: (a, b) => a['_id'] == b['_id'],
          hashCode: (a) => a['_id']?.hashCode ?? 0,
          isValidKey: (a) => true,
        );

        for (final request in requests) {
          final r = await client.send(request);
          final body = await r.readAsString();
          final json =
              Map<String, dynamic>.from(const JsonDecoder().convert(body));
          final articles = json['articles'] as List;

          allArticles.addAll(articles.cast<Map<String, dynamic>>());
        }

        var sortedArticlesByScore = allArticles.toList()
          ..sort((a, b) {
            final rankA = a['_score'] as double? ?? .0,
                rankB = b['_score'] as double? ?? .0;

            return rankB.compareTo(rankA);
          });

        if (sortedArticlesByScore.length > 100) {
          sortedArticlesByScore = sortedArticlesByScore.sublist(0, 100);
        }

        final response = <String, dynamic>{
          "status": "ok",
          "total_hits": sortedArticlesByScore.length,
          "page": 1,
          "total_pages": 1,
          "page_size": sortedArticlesByScore.length,
          "articles": sortedArticlesByScore,
          "user_input": {
            "q": keywordGroups,
            "search_in": ["title_summary"],
            "lang": null,
            "not_lang": null,
            "countries": ["US"],
            "not_countries": null,
            "from": "2021-12-15 00:00:00",
            "to": null,
            "ranked_only": "True",
            "from_rank": null,
            "to_rank": null,
            "sort_by": "relevancy",
            "page": 1,
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
            articles: sortedArticlesByScore,
          ),
        );

        return const JsonEncoder().convert(response);
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
