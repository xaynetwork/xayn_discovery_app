import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_readability/xayn_readability.dart';

const String _kUserAgent =
    'Mozilla/5.0 (Linux; Android 8.0.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.84 Mobile Safari/537.36';

@injectable
class Client implements http.Client {
  final http.Client _client;

  Client() : _client = createHttpClient(userAgent: _kUserAgent);

  @override
  Future close({bool force = false}) => _client.close(force: force);

  @override
  Future<http.Response> send(http.Request request) => _client.send(request);

  Future<http.Response> sendWithRedirectGuard(http.Request request) async {
    final response = await send(request);

    // test if in redirect status code range
    if (response.statusCode >= 300 && response.statusCode < 400) {
      final location = _getNextLocation(response, request.uri);

      logger.i(
          'Redirect detected (${response.statusCode})\nNext location: $location');

      // detect if we got 'set-cookie' headers
      // some sites simply return a 302 and expect then to be called
      // again, but with those cookies then set.
      // this is an anti-scraping measure.
      if (response.headers.containsKey('set-cookie')) {
        logger.i('Server cookies detected');

        return await send(request.change(
          uri: location,
          cookies: _getCookiesToSet(response),
        ));
      }

      return await send(request.change(uri: location));
    }

    return response;
  }

  Uri _getNextLocation(http.Response response, Uri originalUri) {
    final redirects = response.redirects
            ?.map((it) => it.location)
            .map((it) => it.toString())
            .toList() ??
        const <String>[];
    final locations = response.headers['location'] ?? redirects;
    return locations.isNotEmpty ? Uri.parse(locations.last) : originalUri;
  }

  Map<String, String> _getCookiesToSet(http.Response response) {
    final cookies = response.headers['set-cookie']!;

    return Map.fromEntries(
      cookies
          .map((it) => it.split(';'))
          .expand((it) => it)
          .map((it) => it.split('='))
          .where((it) => it.length == 2)
          .map((it) => MapEntry(it.first, it.last)),
    );
  }
}
