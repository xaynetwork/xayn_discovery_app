import 'package:envify/envify.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

/// Standard Env config.
@Envify(path: kReleaseMode ? '.env.prod' : '.env.dev')
abstract class Env {
  static const String searchApiBaseUrl = _Env.searchApiBaseUrl;
  static const String searchApiSecretKey = _Env.searchApiSecretKey;
  static const String imageFetcherUrl = _Env.imageFetcherUrl;
  static const String instabugToken = _Env.instabugToken;
}
