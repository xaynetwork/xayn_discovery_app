import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
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

    if (response.statusCode == 302) {
      // detect if we got 'set-cookie' headers
      // some sites simply return a 302 and expect then to be called
      // again, but with those cookies then set.
      // this is an anti-scraping measure.
      if (response.headers.containsKey('set-cookie')) {
        final serverCookies = response.headers['set-cookie']!;
        final locations = response.headers['location'] ?? const <String>[];
        final cookies = Map.fromEntries(
          serverCookies
              .map((it) => it.split(';'))
              .expand((it) => it)
              .map((it) => it.split('='))
              .where((it) => it.length == 2)
              .map((it) => MapEntry(it.first, it.last)),
        );

        return await send(request.change(
            uri: locations.isNotEmpty ? Uri.parse(locations.last) : request.uri,
            cookies: cookies));
      }
    }

    return response;
  }
}
