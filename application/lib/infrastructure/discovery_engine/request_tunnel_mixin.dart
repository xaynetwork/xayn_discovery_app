import 'dart:convert';
import 'dart:math';

import 'package:http_client/console.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

final List<ResultSet> resultSets = <ResultSet>[];

String reportCurrentResultSets() {
  var body = '';

  for (final resultSet in resultSets) {
    final timeStamp =
        '${resultSet.timestamp.hour}:${resultSet.timestamp.minute}::${resultSet.timestamp.second}';
    final entry =
        '<p><b>[${resultSet.path}][$timeStamp]</b>&nbsp;${const HtmlEscape().convert(resultSet.query)}:&nbsp;${resultSet.articles.length} results received</p>';
    var listing = '<ol>';

    if (resultSet.path != '_lh') {
      var res = resultSet.articles;

      if (res.length > 5) res = res.sublist(0, 5);

      for (final article in res) {
        listing =
            '$listing<li>${article['published_date']}:&nbsp;${const HtmlEscape().convert(article['title'])}</li>';
      }

      listing = '<span>Displaying top 5 results: </span>$listing';
    }

    listing = '$listing</ol>';

    body = '<html><body>$body$entry$listing</body></html>';
  }

  return body;
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
        generateGibberish(int wordCount) {
          final rnd = Random();
          //97
          for (var i = 0; i < wordCount; i++) {
            final wordSize = rnd.nextInt(12) + 2;

            return String.fromCharCodes(
                List.generate(wordSize, (i) => rnd.nextInt(26) + 97));
          }
        }

        final queryParameters =
            Map<String, String>.from(request.url.queryParameters);
        final pageSize = int.parse(queryParameters['page_size'] ?? '100');
        final articles = List.generate(
            pageSize,
            (index) => <String, dynamic>{
                  "title": "$index: ${generateGibberish(6)}",
                  "author": "${generateGibberish(2)}",
                  "published_date": "2022-01-01 12:00:00",
                  "published_date_precision": "full",
                  "link": "https://en.wikipedia.org/wiki/Q*bert",
                  "clean_url": "en.wikipedia.org",
                  "excerpt": "${generateGibberish(20)}.",
                  "summary": "${generateGibberish(50)}.",
                  "rights": "wikipedia.org",
                  "rank": 1000,
                  "topic": "gibberish",
                  "country": "US",
                  "language": "en",
                  "authors": ["${generateGibberish(2)}"],
                  "media":
                      "https://i.insider.com/5a96c069aae605ba008b45c7?width=1136&format=jpeg",
                  "is_opinion": false,
                  "twitter_account": "@${generateGibberish(1)}",
                  "_score": .0,
                  "_id": "${generateGibberish(1)}"
                });
        final response = <String, dynamic>{
          "status": "ok",
          "total_hits": pageSize,
          "page": 1,
          "total_pages": 1,
          "page_size": pageSize,
          "articles": articles,
          "user_input": {
            "q": "${generateGibberish(1)}",
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
