import 'dart:convert';

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
        final queryParameters =
            Map<String, String>.from(request.url.queryParameters);
        final optimisticRequest = _buildActualRequest(
          request,
          uri,
          queryParameters,
        );
        final optimisticMatch = await _performActualApiCall(
          optimisticRequest,
          queryParameters['q'] ?? 'no query',
          request.url.path,
        );
        final optimisticJson = Map<String, dynamic>.from(
            const JsonDecoder().convert(optimisticMatch) as Map);
        final optimisticCount = optimisticJson['articles'].length as int;

        if (optimisticCount < 100) {
          final rest = 100 - optimisticCount;

          queryParameters['page_size'] = '$rest';

          final expr = RegExp(r'\(([^\)]+)\)');
          final q = queryParameters['q'] ?? '';
          final groups = expr.allMatches(q);
          final qry = <String>[];

          for (final group in groups) {
            final terms = group.group(1) ?? '';
            final words = terms
                .split(' ')
                .where((it) => it.length > 3)
                .toList(growable: false);

            qry.add('(${words.join(' ')}) OR (${words.join(' || ')})');
          }

          if (qry.isNotEmpty) {
            queryParameters['q'] = qry.join(' OR ');

            final fuzzyRequest = _buildActualRequest(
              request,
              uri,
              queryParameters,
            );

            final fuzzyMatch = await _performActualApiCall(
              fuzzyRequest,
              queryParameters['q'] ?? 'no query',
              request.url.path,
            );

            final fuzzyJson = const JsonDecoder().convert(fuzzyMatch) as Map;

            optimisticJson['articles'] = [
              ...optimisticJson['articles'],
              ...fuzzyJson['articles']
            ];
            optimisticJson['total_hits'] =
                '${optimisticJson['articles'].length as int}';

            return const JsonEncoder().convert(optimisticJson);
          }
        }

        return optimisticMatch;
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
