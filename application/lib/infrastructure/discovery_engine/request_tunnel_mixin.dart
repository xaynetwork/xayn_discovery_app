import 'dart:convert';

import 'package:http_client/console.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

mixin RequestTunnelMixin {
  late final client = http.ConsoleClient();

  Future<void> startRequestTunneling(String url) async {
    final handler = const Pipeline().addHandler(_echoRequest(Uri.parse(url)));

    await shelf_io.serve(handler, 'localhost', 1234);
  }

  Future<Response> Function(Request) _echoRequest(Uri uri) =>
      (Request request) async {
        const days = [3, 7, 14, 30, 100, 365, 1000];
        var index = 0;
        _Result? result;

        while (index < days.length &&
            (result == null || result.articleCount < 5)) {
          result = await _doRequest(uri)(request, days[index++]);
        }

        return Response.ok(result!.body);
      };

  Future<_Result> Function(Request, int) _doRequest(Uri uri) =>
      (Request request, int dateOffset) async {
        final queryParameters =
            Map<String, String>.from(request.url.queryParameters);

        if (queryParameters.containsKey('sort_by')) {
          queryParameters['sort_by'] = 'date';
        }

        if (queryParameters.containsKey('from')) {
          final d = DateTime.now().subtract(Duration(days: dateOffset));
          final from = '${d.year}/${d.month}/${d.day}';

          queryParameters['from'] = from;
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

        return _Result(
          body: body,
          articleCount: json['articles']?.length ?? -1,
        );
      };
}

class _Result {
  final String body;
  final int articleCount;

  const _Result({required this.body, required this.articleCount});
}
