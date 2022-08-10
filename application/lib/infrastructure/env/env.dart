import 'package:envify/envify.dart';
// This allows to use this file from outside like bin/
// ignore: implementation_imports
import 'package:flutter/src/foundation/constants.dart';
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
  static const String revenueCatSdkKeyIos = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.revenueCatSdkKeyIos
      : _EnvProd.revenueCatSdkKeyIos;

  static const String revenueCatSdkKeyAndroid =
      EnvironmentHelper.kIsInternalFlavor
          ? _EnvDev.revenueCatSdkKeyAndroid
          : _EnvProd.revenueCatSdkKeyAndroid;

  static const String mixpanelServerUrl = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.mixpanelServerUrl
      : _EnvProd.mixpanelServerUrl;
  static const String rconfigAccessKey = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.rconfigAccessKey
      : _EnvProd.rconfigAccessKey;
  static const String rconfigSecretKey = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.rconfigSecretKey
      : _EnvProd.rconfigSecretKey;
  static const String rconfigRegion = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.rconfigRegion
      : _EnvProd.rconfigRegion;
  static const String rconfigEndpointUrl = EnvironmentHelper.kIsInternalFlavor
      ? _EnvDev.rconfigEndpointUrl
      : _EnvProd.rconfigEndpointUrl;
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
  static const String rconfigAccessKey = __EnvDev.rconfigAccessKey;
  static const String rconfigSecretKey = __EnvDev.rconfigSecretKey;
  static const String rconfigEndpointUrl = __EnvDev.rconfigEndpointUrl;
  static const String rconfigRegion = __EnvDev.rconfigRegion;
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
  static const String rconfigAccessKey = __EnvProd.rconfigAccessKey;
  static const String rconfigSecretKey = __EnvProd.rconfigSecretKey;
  static const String rconfigEndpointUrl = __EnvProd.rconfigEndpointUrl;
  static const String rconfigRegion = __EnvProd.rconfigRegion;
}
