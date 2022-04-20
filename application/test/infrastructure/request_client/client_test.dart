import 'package:flutter_test/flutter_test.dart';
import 'package:http_client/http_client.dart' as http;
import 'package:xayn_discovery_app/domain/http_requests/common_params.dart';
import 'package:xayn_discovery_app/infrastructure/request_client/client.dart';

void main() {
  late Client client;

  setUp(() {
    client = Client();
  });

  test('Redirect with Set-Cookie ignores invalid cookies', () async {
    final response = await client.send(
      http.Request(
        CommonHttpRequestParams.httpRequestGet,
        'https://www.tnonline.com/20220226/public-notice-panther-valley-school-district-advertisement-invitation-3',
        followRedirects: false,
        headers: CommonHttpRequestParams.httpRequestHeaders,
        timeout: CommonHttpRequestParams.httpRequestTimeout,
      ),
    );

    expect(response.statusCode, 200);
  });

  test('Redirect with Set-Cookie ignores previously set cookies', () async {
    final response = await client.send(
      http.Request(
        CommonHttpRequestParams.httpRequestGet,
        'https://news.google.com/__i/rss/rd/articles/CBMiXGh0dHBzOi8vd3d3Lndhc2hpbmd0b25wb3N0LmNvbS93b3JsZC8yMDIyLzAyLzI1L3VrcmFpbmUtcnVzc2lhLWNoZXJub2J5bC1ob3N0YWdlcy1yYWRpYXRpb24v0gEA?oc=5',
        followRedirects: false,
        headers: CommonHttpRequestParams.httpRequestHeaders,
        timeout: CommonHttpRequestParams.httpRequestTimeout,
      ),
    );

    expect(response.statusCode, 200);
  });
}
