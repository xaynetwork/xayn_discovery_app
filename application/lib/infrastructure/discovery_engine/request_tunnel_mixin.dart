import 'dart:convert';

import 'package:http_client/console.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

mixin RequestTunnelMixin {
  late final client = http.ConsoleClient();

  Future<void> startRequestTunneling(String url) async {
    final handler = const Pipeline().addHandler(_echoRequest(Uri.parse(url)));

    await shelf_io.serve(handler, 'localhost', 1234);
  }

  Future<Response> Function(Request) _echoRequest(Uri uri) =>
      (Request request) async {
        final result = await _doRequest(uri)(request);

        return Response.ok(result.body);
      };

  Future<_Result> Function(Request) _doRequest(Uri uri) =>
      (Request request) async {
        final queryParameters =
            Map<String, String>.from(request.url.queryParameters);
        final isKeywordLookup = request.url.path == '_sn';

        if (isKeywordLookup) {
          if (!queryParameters.containsKey('from')) {
            final fromDate = DateTime.now().subtract(const Duration(days: 30));

            queryParameters['from'] =
                '${fromDate.year}/${fromDate.month}/${fromDate.day}';
          }

          if (queryParameters.containsKey('page_size')) {
            queryParameters['page_size'] = '100';
          }
        }

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
        final articles = List.from(json['articles'] as List? ?? const [])
          ..sort((a, b) => DateTime.parse(a['published_date'])
              .compareTo(DateTime.parse(b['published_date'])));

        if (isKeywordLookup) {
          final dateThreshold = articles.isNotEmpty
              ? DateTime.parse(articles.first['published_date'])
              : DateTime.now();
          final articlesToKeep = <Map<String, dynamic>>[];

          logger.i('Request: $actualUri, result count: ${articles.length}');

          for (final Map<String, dynamic> article in articles) {
            final datePublished = DateTime.parse(article['published_date']);

            if (articlesToKeep.length < 20 ||
                datePublished.difference(dateThreshold) <
                    const Duration(days: 7)) {
              articlesToKeep.add(article);
            } else {
              logger.i('removed old article from $datePublished');
            }
          }

          json = Map<String, dynamic>.from(json)..['articles'] = articlesToKeep;
        }

        return _Result(
          body: const JsonEncoder().convert(json),
          articleCount: articles.length,
        );
      };
}

class _Result {
  final String body;
  final int articleCount;

  const _Result({required this.body, required this.articleCount});
}
