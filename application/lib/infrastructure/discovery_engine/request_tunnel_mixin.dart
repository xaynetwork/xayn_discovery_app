import 'dart:convert';
import 'dart:developer';

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
      for (final article in resultSet.articles) {
        listing =
            '$listing<li>${article['published_date']}:&nbsp;${const HtmlEscape().convert(article['title'])}</li>';
      }
    }

    listing = '$listing</ol>';

    body = '<html><body>$body$entry$listing</body></html>';
  }

  return body;
}

mixin RequestTunnelMixin {
  late final client = http.ConsoleClient();

  Future<void> startRequestTunneling(String url) async {
    final handler = const Pipeline().addHandler(_echoRequest(Uri.parse(url)));

    await shelf_io.serve(handler, 'localhost', 1234);
  }

  Future<Response> Function(Request) _echoRequest(Uri uri) =>
      (Request request) async {
        final result = await _doRequest(uri)(request);
        log(result);
        return Response.ok(result);
      };

  Future<String> Function(Request) _doRequest(Uri uri) =>
      (Request request) async {
        final queryParameters =
            Map<String, String>.from(request.url.queryParameters);
        final actualUri = request.url.replace(
          scheme: uri.scheme,
          host: uri.host,
          port: uri.port,
          queryParameters: queryParameters,
        );
        final headers = Map<String, String>.from(request.headers);

        headers['host'] = uri.host;

        final actualRequest = http.Request(
          request.method,
          actualUri,
          headers: headers,
          encoding: request.encoding,
        );

        final response = await client.send(actualRequest);
        final body = await response.readAsString();
        var json = const JsonDecoder().convert(body) as Map;
        final rawArticles = List.from(json['articles'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .toList(growable: false);

        resultSets.add(ResultSet(
          timestamp: DateTime.now(),
          path: request.url.path,
          query: queryParameters['q'] ?? 'no query',
          articles: rawArticles,
        ));

        return body;
      };
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
