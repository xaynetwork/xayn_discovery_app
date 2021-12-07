import 'package:envify/envify.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

abstract class Env {
  static const String searchApiBaseUrl =
      kReleaseMode ? _EnvProd.searchApiBaseUrl : _EnvDev.searchApiBaseUrl;
  static const String searchApiSecretKey =
      kReleaseMode ? _EnvProd.searchApiSecretKey : _EnvDev.searchApiSecretKey;
  static const String imageFetcherUrl =
      kReleaseMode ? _EnvProd.imageFetcherUrl : _EnvDev.imageFetcherUrl;
  static const String instabugToken =
      kReleaseMode ? _EnvProd.instabugToken : _EnvDev.instabugToken;
}

/// Standard Env config.
@Envify(path: '.env.dev')
abstract class _EnvDev {
  static const String searchApiBaseUrl = __EnvDev.searchApiBaseUrl;
  static const String searchApiSecretKey = __EnvDev.searchApiSecretKey;
  static const String imageFetcherUrl = __EnvDev.imageFetcherUrl;
  static const String instabugToken = __EnvDev.instabugToken;
}

/// Standard Env config.
@Envify(path: '.env.prod')
abstract class _EnvProd {
  static const String searchApiBaseUrl = __EnvProd.searchApiBaseUrl;
  static const String searchApiSecretKey = __EnvProd.searchApiSecretKey;
  static const String imageFetcherUrl = __EnvProd.imageFetcherUrl;
  static const String instabugToken = __EnvProd.instabugToken;
}
