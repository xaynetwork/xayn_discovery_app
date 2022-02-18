import 'dart:io';

import 'package:envify/envify.dart';
import 'package:flutter/foundation.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

part 'env.g.dart';

abstract class Env {
  static const String searchApiBaseUrl =
      kReleaseMode ? _EnvProd.searchApiBaseUrl : _EnvDev.searchApiBaseUrl;
  static const String searchApiSecretKey =
      kReleaseMode ? _EnvProd.searchApiSecretKey : _EnvDev.searchApiSecretKey;
  static const String imageFetcherUrl =
      kReleaseMode ? _EnvProd.imageFetcherUrl : _EnvDev.imageFetcherUrl;
  static const String instabugToken = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.instabugToken
      : _EnvProd.instabugToken;
  static const String amplitudeApiKey = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.amplitudeApiKey
      : _EnvProd.amplitudeApiKey;
  static const String appsflyerDevKey = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.appsflyerDevKey
      : _EnvProd.appsflyerDevKey;
  static const String appStoreNumericalId = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.appStoreNumericalId
      : _EnvProd.appStoreNumericalId;
  static final String revenueCatSdkKey = EnvironmentHelper.kIsInternalFlavor
      ? (Platform.isIOS
          ? _EnvDev.revenueCatSdkKeyIos
          : _EnvDev.revenueCatSdkKeyAndroid)
      : (Platform.isIOS
          ? _EnvProd.revenueCatSdkKeyIos
          : _EnvProd.revenueCatSdkKeyAndroid);
}

/// Standard Env config.
@Envify(path: '.env.dev')
abstract class _EnvDev {
  static const String searchApiBaseUrl = __EnvDev.searchApiBaseUrl;
  static const String searchApiSecretKey = __EnvDev.searchApiSecretKey;
  static const String imageFetcherUrl = __EnvDev.imageFetcherUrl;
  static const String instabugToken = __EnvDev.instabugToken;
  static const String amplitudeApiKey = __EnvDev.amplitudeApiKey;
  static const String appsflyerDevKey = __EnvDev.appsflyerDevKey;
  static const String appStoreNumericalId = __EnvDev.appStoreNumericalId;
  static const String revenueCatSdkKeyIos = __EnvDev.revenueCatSdkKeyIos;
  static const String revenueCatSdkKeyAndroid =
      __EnvDev.revenueCatSdkKeyAndroid;
}

/// Standard Env config.
@Envify(path: '.env.prod')
abstract class _EnvProd {
  static const String searchApiBaseUrl = __EnvProd.searchApiBaseUrl;
  static const String searchApiSecretKey = __EnvProd.searchApiSecretKey;
  static const String imageFetcherUrl = __EnvProd.imageFetcherUrl;
  static const String instabugToken = __EnvProd.instabugToken;
  static const String amplitudeApiKey = __EnvProd.amplitudeApiKey;
  static const String appsflyerDevKey = __EnvProd.appsflyerDevKey;
  static const String appStoreNumericalId = __EnvProd.appStoreNumericalId;
  static const String revenueCatSdkKeyIos = __EnvProd.revenueCatSdkKeyIos;
  static const String revenueCatSdkKeyAndroid =
      __EnvProd.revenueCatSdkKeyAndroid;
}
