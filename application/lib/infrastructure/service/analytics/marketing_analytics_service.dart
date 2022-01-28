import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

abstract class MarketingAnalyticsService {
  void send(AnalyticsEvent event);
}

@LazySingleton(as: MarketingAnalyticsService)
class AppsFlyerMarketingAnalyticsService implements MarketingAnalyticsService {
  final AppsflyerSdk _appsflyer;

  @visibleForTesting
  AppsFlyerMarketingAnalyticsService(this._appsflyer) {
    _appsflyer.onAppOpenAttribution(_onAppOpenAttribution);
    _appsflyer.onInstallConversionData(_onInstallConversionData);
    _appsflyer.onDeepLinking(_onDeepLinking);
  }

  @factoryMethod
  static MarketingAnalyticsService initialized(PackageInfo packageInfo) {
    final appId =
        Platform.isIOS ? Env.appStoreNumericalId : EnvironmentHelper.kAppId;

    final options = AppsFlyerOptions(
      showDebug: EnvironmentHelper.kIsDebug,
      afDevKey: Env.appsflyerDevKey,
      appId: appId,
      disableAdvertisingIdentifier: true,
    );

    final appsFlyer = AppsflyerSdk(options);
    appsFlyer.initSdk();
    return AppsFlyerMarketingAnalyticsService(appsFlyer);
  }

  @override
  void send(AnalyticsEvent event) {
    logger.i('Marketing Analytics event has been fired: ' + event.type);
    _appsflyer.logEvent(event.type, event.properties);
  }

  _onAppOpenAttribution(res) =>
      logger.i('Marketing Analytics onAppOpenAttribution: ' + res.toString());

  _onInstallConversionData(res) => logger
      .i('Marketing Analytics onInstallConversionData: ' + res.toString());

  _onDeepLinking(res) =>
      logger.i('Marketing Analytics onDeepLinking: ' + res.toString());
}
