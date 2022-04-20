import 'dart:io';

import 'package:http_client/console.dart' as client;
import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

const String _kUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.82 Safari/537.36';
const int _kMaxRedirectCount = 10;
const String _kConnectionClosed =
    'connection closed before full header was received';
const Duration _kRetryTimeout = Duration(seconds: 1);

@injectable
class Client implements http.Client {
  late final http.Client _client = client.ConsoleClient(
    userAgent: _kUserAgent,
    ignoreBadCertificates: true,
  );

  @override
  Future close({bool force = false}) => _client.close(force: force);

  @override
  Future<http.Response> send(http.Request request) =>
      _sendWithRedirectGuard(request);

  Future<http.Response> _sendWithRedirectGuard(
    http.Request request, {
    int count = 0,
  }) async {
    if (count >= _kMaxRedirectCount) throw MaxRedirectError(count);

    final response = await _client.send(request).catchError(
      (e) async {
        // "connection closed before full header was received" appears to be a Flutter issue
        // I couldn't reproduce it myself, but the issue thread did suggest a retry when it triggers.
        await Future.delayed(_kRetryTimeout);

        return _sendWithRedirectGuard(request, count: count + 1);
      },
      test: (e) =>
          e is HttpException &&
          e.message.toLowerCase().startsWith(_kConnectionClosed),
    );

    // test if in redirect status code range
    if (response.isRedirect) {
      final location = _getNextLocation(response, request.uri);
      final hasSetCookie = response.headers.containsKey('set-cookie');

      if (request.uri == location && !hasSetCookie) throw SameRedirectError();

      logger.i(
          'Redirect detected (${response.statusCode})\nNext location: $location');

      // detect if we got 'set-cookie' headers
      // some sites simply return a 302 and expect then to be called
      // again, but with those cookies then set.
      // this is an anti-scraping measure.
      if (hasSetCookie) {
        logger.i('Server cookies detected');

        return await _sendWithRedirectGuard(
          request.change(
            uri: location,
            headers: request.headers.clone()..remove('cookie'),
            cookies: _getCookiesToSet(response.headers['set-cookie']!),
          ),
          count: count + 1,
        );
      }

      return await _sendWithRedirectGuard(
        request.change(uri: location),
        count: count + 1,
      );
    }

    return response;
  }

  Uri _getNextLocation(http.Response response, Uri originalUri) {
    late final redirects = response.redirects
            ?.map((it) => it.location)
            .map((it) => it.toString())
            .toList() ??
        const <String>[];
    final locations = response.headers['location'] ?? redirects;

    return locations.isNotEmpty
        ? originalUri.resolve(locations.last)
        : originalUri;
  }

  Map<String, String> _getCookiesToSet(List<String> rawCookies) {
    final cookieMap = <String, String>{};

    for (final it in rawCookies) {
      try {
        final cookie = Cookie.fromSetCookieValue(it);

        cookieMap[cookie.name] = cookie.value;
      } catch (e) {
        // ignore invalid cookies
      }
    }

    return cookieMap;
  }
}

extension _IsRedirectExtension on http.Response {
  bool get isRedirect => statusCode >= 300 && statusCode < 400;
}

class ClientError extends Error {
  final String message;

  ClientError(this.message);

  @override
  String toString() => message;
}

class MaxRedirectError extends ClientError {
  final int numRedirects;

  MaxRedirectError(this.numRedirects) : super('redirect loop detected');
}

class SameRedirectError extends ClientError {
  SameRedirectError() : super('redirect same url detected');
}
