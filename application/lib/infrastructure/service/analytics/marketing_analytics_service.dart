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
  /// These in-app events help marketers understand how loyal users
  /// discover your app, and attribute them to specific campaigns/media-sources.
  /// It aids in measuring ROI (Return on Investment) and LTV (Lifetime Value).
  void send(AnalyticsEvent event);

  void optOut(bool state);

  void setPushNotification(bool isEnabled);

  /// TODO: call this function in language change
  void setCurrentDeviceLanguage(String language);

  Future<String?> getUID();
}

@LazySingleton(as: MarketingAnalyticsService)
class AppsFlyerMarketingAnalyticsService implements MarketingAnalyticsService {
  final AppsflyerSdk _appsflyer;

  @visibleForTesting
  AppsFlyerMarketingAnalyticsService(this._appsflyer) {
    _appsflyer.setPushNotification(true);
    _appsflyer.onAppOpenAttribution(_onAppOpenAttribution);
    _appsflyer.onInstallConversionData(_onInstallConversionData);
    _appsflyer.onDeepLinking(_onDeepLinking);
  }

  @factoryMethod
  static MarketingAnalyticsService initialized(PackageInfo packageInfo) {
    final options = Platform.isIOS
        ? AppsFlyerOptions(
            showDebug: EnvironmentHelper.kIsDebug,
            afDevKey: Env.appsflyerDevKey,
            appId: Env.appStoreNumericalId,
            disableAdvertisingIdentifier: true,
          )
        : AppsFlyerOptions(
            showDebug: EnvironmentHelper.kIsDebug,
            afDevKey: Env.appsflyerDevKey,
            appId: EnvironmentHelper.kAppId,
            disableAdvertisingIdentifier: false,
          );

    final appsFlyer = AppsflyerSdk(options);
    appsFlyer.initSdk(
      /// NOTE: when sending registerOnDeepLinkingCallback flag, the sdk will
      /// ignore onAppOpenAttribution (registerOnAppOpenAttributionCallback flag)!
      ///
      registerOnDeepLinkingCallback: false,

      registerConversionDataCallback: false,
      registerOnAppOpenAttributionCallback: false,
    );
    return AppsFlyerMarketingAnalyticsService(appsFlyer);
  }

  /// The logEvent method allows you to send in-app events to AppsFlyer analytics.
  @override
  void send(AnalyticsEvent event) {
    logger.i('Marketing Analytics event has been fired: ' + event.type);
    _appsflyer.logEvent(event.type, event.properties);
  }

  @override
  void optOut(bool isOptOut) {
    /// Stop sending in-app events
    _appsflyer.stop(isOptOut);

    /// Stop tracking location
    _appsflyer.enableLocationCollection(!isOptOut);

    /// Stop collecting AndroidId for Android
    if (Platform.isAndroid) _appsflyer.setCollectAndroidId(!isOptOut);

    /// Use this API in order to disable the SK Ad network
    /// Request will be sent but the rules won't be returned.
    if (Platform.isIOS) _appsflyer.disableSKAdNetwork(isOptOut);
  }

  /// For Android: Make sure to call this API inside the page of every activity that is launched after clicking the notification.
  ///
  /// For iOS: This API can be called once at the initialization phase.
  ///
  /// Please check the following guide in order to understand the relevant payload needed for AppsFlyer to attribute the push notification:
  /// https://support.appsflyer.com/hc/en-us/articles/207364076-Measuring-push-notification-re-engagement-campaigns
  ///
  @override
  void setPushNotification(bool isEnabled) =>
      _appsflyer.setPushNotification(isEnabled);

  /// Use this API in order to set the language
  /// e.g.: setCurrentDeviceLanguage('en');
  @override
  void setCurrentDeviceLanguage(String language) =>
      _appsflyer.setCurrentDeviceLanguage(language);

  @override
  Future<String?> getUID() => _appsflyer.getAppsFlyerUID();

  /// Handle the Direct Deeplinking with [_onAppOpenAttribution]
  ///
  /// Direct Deep Linking - Directly serving personalized content to existing
  /// users, which already have the mobile app installed.
  ///
  /// For testing purposes we send in-app events when [_onAppOpenAttribution] handler is triggered
  _onAppOpenAttribution(DeepLinkResult res) {
    if (res.status == Status.FOUND) {
      _appsflyer.logEvent(
          'onAppOpenAttribution', res.deepLink?.clickEvent ?? {});
    }
  }

  /// Handle the Deferred deeplink with [_onInstallConversionData]
  ///
  /// Deferred Deep Linking is Serving personalized content to new or former
  /// users, directly after the installation.
  ///
  /// For testing purposes we send in-app events when [_onInstallConversionData] handler is triggered
  ///
  _onInstallConversionData(DeepLinkResult res) {
    if (res.status == Status.FOUND) {
      _appsflyer.logEvent(
          'onInstallConversionData', res.deepLink?.clickEvent ?? {});
    }
  }

  /// Handle the Unified deep linking with [_onDeepLinking]
  ///
  /// Unified deep linking - Unified deep linking sends new and existing users
  /// to a specific in-app activity as soon as the app is opened.
  ///
  /// For testing purposes we send in-app events when [_onDeepLinking] handler is triggered
  ///
  _onDeepLinking(DeepLinkResult res) {
    if (res.status == Status.FOUND) {
      _appsflyer.logEvent('onDeepLinking', res.deepLink?.clickEvent ?? {});
    }
  }
}
