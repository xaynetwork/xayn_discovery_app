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

        if (request.url.path == '_sn') {
          if (!queryParameters.containsKey('from')) {
            final fromDate = DateTime.now().subtract(const Duration(days: 30));

            queryParameters['from'] =
                '${fromDate.year}/${fromDate.month}/${fromDate.day}';
          }

          if (queryParameters.containsKey('sort_by')) {
            queryParameters['sort_by'] = 'date';
          }

          if (queryParameters.containsKey('page_size')) {
            queryParameters['page_size'] = '20';
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
        final json = const JsonDecoder().convert(body) as Map;
        final articles = json['articles'] as List? ?? const [];

        logger.i('Request: $actualUri, result count: ${articles.length}');

        return _Result(
          body: body,
          articleCount: articles.length,
        );
      };
}

class _Result {
  final String body;
  final int articleCount;

  const _Result({required this.body, required this.articleCount});
}
