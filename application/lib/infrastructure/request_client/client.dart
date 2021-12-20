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
}
