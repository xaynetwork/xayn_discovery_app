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
  static const String mixpanelToken = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.mixpanelToken
      : _EnvProd.mixpanelToken;
  static const String appsflyerDevKey = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.appsflyerDevKey
      : _EnvProd.appsflyerDevKey;
  static const String appStoreNumericalId = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.appStoreNumericalId
      : _EnvProd.appStoreNumericalId;
  static const String aiAssetsUrl = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.aiAssetsUrl
      : _EnvProd.aiAssetsUrl;
  static final String revenueCatSdkKey = EnvironmentHelper.kIsInternalFlavor
      ? (Platform.isIOS
          ? _EnvDev.revenueCatSdkKeyIos
          : _EnvDev.revenueCatSdkKeyAndroid)
      : (Platform.isIOS
          ? _EnvProd.revenueCatSdkKeyIos
          : _EnvProd.revenueCatSdkKeyAndroid);
  static const String mixpanelServerUrl = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.mixpanelServerUrl
      : _EnvProd.mixpanelServerUrl;
}

/// Standard Env config.
@Envify(path: '.env.dev')
abstract class _EnvDev {
  static const String searchApiBaseUrl = __EnvDev.searchApiBaseUrl;
  static const String searchApiSecretKey = __EnvDev.searchApiSecretKey;
  static const String imageFetcherUrl = __EnvDev.imageFetcherUrl;
  static const String instabugToken = __EnvDev.instabugToken;
  static const String mixpanelToken = __EnvDev.mixpanelToken;
  static const String appsflyerDevKey = __EnvDev.appsflyerDevKey;
  static const String appStoreNumericalId = __EnvDev.appStoreNumericalId;
  static const String aiAssetsUrl = __EnvDev.aiAssetsUrl;
  static const String revenueCatSdkKeyIos = __EnvDev.revenueCatSdkKeyIos;
  static const String revenueCatSdkKeyAndroid =
      __EnvDev.revenueCatSdkKeyAndroid;
  static const String mixpanelServerUrl = __EnvDev.mixpanelServerUrl;
}

/// Standard Env config.
@Envify(path: '.env.prod')
abstract class _EnvProd {
  static const String searchApiBaseUrl = __EnvProd.searchApiBaseUrl;
  static const String searchApiSecretKey = __EnvProd.searchApiSecretKey;
  static const String imageFetcherUrl = __EnvProd.imageFetcherUrl;
  static const String instabugToken = __EnvProd.instabugToken;
  static const String mixpanelToken = __EnvProd.mixpanelToken;
  static const String appsflyerDevKey = __EnvProd.appsflyerDevKey;
  static const String appStoreNumericalId = __EnvProd.appStoreNumericalId;
  static const String aiAssetsUrl = __EnvProd.aiAssetsUrl;
  static const String revenueCatSdkKeyIos = __EnvProd.revenueCatSdkKeyIos;
  static const String revenueCatSdkKeyAndroid =
      __EnvProd.revenueCatSdkKeyAndroid;
  static const String mixpanelServerUrl = __EnvProd.mixpanelServerUrl;
}
