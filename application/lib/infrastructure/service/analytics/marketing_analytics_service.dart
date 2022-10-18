import 'dart:async';
import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/deep_link/retrieve_deep_link_data_use_case.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

import '../../../domain/model/analytics/generate_invite_link_result.dart';
import 'constants/analytics_constants.dart';

abstract class MarketingAnalyticsService {
  /// These in-app events help marketers understand how loyal users
  /// discover your app, and attribute them to specific campaigns/media-sources.
  /// It aids in measuring ROI (Return on Investment) and LTV (Lifetime Value).
  void send(AnalyticsEvent event);

  void optOut(bool state);

  /// TODO: call this function in language change
  void setCurrentDeviceLanguage(String language);

  Future<GenerateInviteLinkResult> generateLinkForSharingArticle({
    required String encodedArticleData,
  });

  Future<String?> getUID();
}

@LazySingleton(as: MarketingAnalyticsService)
@releaseEnvironment
class AppsFlyerMarketingAnalyticsService implements MarketingAnalyticsService {
  final DeepLinkManager _deepLinkManager;
  final AppsflyerSdk _appsflyer;
  final RetrieveDeepLinkDataUseCase _retrieveDeepLinkDataUseCase;

  @visibleForTesting
  AppsFlyerMarketingAnalyticsService(
    this._appsflyer,
    this._deepLinkManager,
    this._retrieveDeepLinkDataUseCase,
  ) {
    _appsflyer.onDeepLinking(_onDeepLinking);
    _appsflyer.setMinTimeBetweenSessions(60);
    _appsflyer.setPushNotification(true);
  }

  @factoryMethod
  static MarketingAnalyticsService initialized(
    AppStatusRepository appStatusRepository,
    DeepLinkManager deepLinkManager,
    RetrieveDeepLinkDataUseCase retrieveDeepLinkDataUseCase,
  ) {
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
    appsFlyer.initSdk(registerOnDeepLinkingCallback: true);
    final userId = appStatusRepository.appStatus.userId.value;
    appsFlyer.setCustomerUserId(userId);

    return AppsFlyerMarketingAnalyticsService(
      appsFlyer,
      deepLinkManager,
      retrieveDeepLinkDataUseCase,
    );
  }

  /// The logEvent method allows you to send in-app events to AppsFlyer analytics.
  @override
  void send(AnalyticsEvent event) {
    logger.i('Marketing Analytics event has been fired: ${event.type}');
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

  /// Use this API in order to set the language
  /// e.g.: setCurrentDeviceLanguage('en');
  @override
  void setCurrentDeviceLanguage(String language) =>
      _appsflyer.setCurrentDeviceLanguage(language);

  @override
  Future<String?> getUID() => _appsflyer.getAppsFlyerUID();

  /// Handle the Unified deep linking with [_onDeepLinking]
  ///
  /// Unified deep linking - Unified deep linking sends new and existing users
  /// to a specific in-app activity as soon as the app is opened.
  ///
  /// It handles Deferred & Direct Deep link in a single callback
  ///
  _onDeepLinking(dynamic res) async {
    if (res is DeepLinkResult && res.status == Status.FOUND) {
      final deepLinkData = await _retrieveDeepLinkDataUseCase.singleOutput(res);
      _deepLinkManager.onDeepLink(deepLinkData);
    }
  }

  @override
  Future<GenerateInviteLinkResult> generateLinkForSharingArticle({
    required String encodedArticleData,
  }) async {
    _appsflyer.setAppInviteOneLinkID(
        AnalyticsConstants.appInviteOneLinkID, (_) {});

    final completer = Completer<GenerateInviteLinkResult>();

    _appsflyer.generateInviteLink(
      _buildAppsFlyerInviteLinkParams(
        deepLinkName: AnalyticsConstants.deepLinkNameForSharingDocument,
        encodedArticleData: encodedArticleData,
      ),
      (map) {
        completer.complete(GenerateInviteLinkSuccess.fromMap(map));
      },
      (error) {
        completer.complete(GenerateInviteLinkError(message: error));
      },
    );
    return completer.future;
  }

  AppsFlyerInviteLinkParams _buildAppsFlyerInviteLinkParams({
    required String deepLinkName,
    required String encodedArticleData,
  }) =>
      AppsFlyerInviteLinkParams(
        customParams: {
          AnalyticsConstants.articleLinkParamName: encodedArticleData,
          AnalyticsConstants.deepLinkNameParamName: deepLinkName,
          // AnalyticsConstants.afWebDp:
          //     AnalyticsConstants.webArticleViewerEndpoint,
          // 'af_dp': AnalyticsConstants.webArticleViewerEndpoint,
          // AnalyticsConstants.afAndroidUrl:
          //     AnalyticsConstants.webArticleViewerEndpoint,
          // AnalyticsConstants.afIOSUrl:
          //     AnalyticsConstants.webArticleViewerEndpoint,
        },
      );
}

/// Appsflyer is disabled in debug mode
@LazySingleton(as: MarketingAnalyticsService)
@debugEnvironment
@testEnvironment
class MarketingAnalyticsServiceDebugMode implements MarketingAnalyticsService {
  @override
  void send(AnalyticsEvent event) =>
      logger.i('DEBUG: Marketing Analytics event has been fired:\n${{
        'type': event.type,
        'properties': event.properties,
      }}');

  @override
  void optOut(bool state) => logger.i('DEBUG: Marketing Analytics opt Out');

  @override
  void setCurrentDeviceLanguage(String language) =>
      logger.i('DEBUG: Marketing Analytics language is set to $language');

  @override
  Future<String?> getUID() async => null;

  @override
  Future<GenerateInviteLinkResult> generateLinkForSharingArticle({
    required String encodedArticleData,
  }) async =>
      GenerateInviteLinkError();
}
