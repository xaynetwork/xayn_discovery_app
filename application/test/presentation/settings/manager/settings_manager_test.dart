import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/subscription_action_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_management_url_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';

import '../../../test_utils/utils.dart';

void main() {
  const appVersion = AppVersion(version: '1.2.3', build: '321');
  const appTheme = AppTheme.dark;
  final subscriptionStatus = SubscriptionStatus.initial();
  const subscriptionManagementURL = 'https://example.com';
  const userId = 'user_id';
  final stateReady = SettingsScreenState.ready(
    theme: appTheme,
    appVersion: appVersion,
    isPaymentEnabled: false,
    arePushNotificationsActive: false,
    areLocalNotificationsEnabled: false,
    areRemoteNotificationsEnabled: false,
    isTopicsEnabled: false,
    subscriptionStatus: subscriptionStatus,
  );

  late MockFeatureManager featureManager;
  late MockGetAppVersionUseCase getAppVersionUseCase;
  late MockGetAppThemeUseCase getAppThemeUseCase;
  late MockSaveAppThemeUseCase saveAppThemeUseCase;
  late MockListenAppThemeUseCase listenAppThemeUseCase;
  late MockBugReportingService bugReportingService;
  late MockExtractLogUseCase extractLogUseCase;
  late MockUrlOpener urlOpener;
  late MockShareUriUseCase shareUriUseCase;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockListenSubscriptionStatusUseCase listenSubscriptionStatusUseCase;
  late MockHapticFeedbackMediumUseCase hapticFeedbackMediumUseCase;
  late MockGetSubscriptionManagementUrlUseCase
      getSubscriptionManagementUrlUseCase;
  late MockSendAnalyticsUseCase sendAnalyticsUseCase;
  late MockTogglePushNotificationsStatusUseCase
      togglePushNotificationsStatusUseCase;
  late MockRatingDialogManager ratingDialogManager;
  late MockAppManager appManager;
  late MockLocalNotificationsService localNotificationsService;
  late MockRemoteNotificationsService remoteNotificationsService;
  late MockDiscoveryFeedManager discoveryFeedManager;
  late MockGetUserIdUseCase getUserIdUseCase;
  late MockAreLocalNotificationsAllowedUseCase
      areLocalNotificationsAllowedUseCase;

  setUp(() {
    featureManager = MockFeatureManager();
    getAppVersionUseCase = MockGetAppVersionUseCase();
    getAppThemeUseCase = MockGetAppThemeUseCase();
    saveAppThemeUseCase = MockSaveAppThemeUseCase();
    listenAppThemeUseCase = MockListenAppThemeUseCase();
    bugReportingService = MockBugReportingService();
    extractLogUseCase = MockExtractLogUseCase();
    urlOpener = MockUrlOpener();
    shareUriUseCase = MockShareUriUseCase();
    getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
    listenSubscriptionStatusUseCase = MockListenSubscriptionStatusUseCase();
    hapticFeedbackMediumUseCase = MockHapticFeedbackMediumUseCase();
    getSubscriptionManagementUrlUseCase =
        MockGetSubscriptionManagementUrlUseCase();
    sendAnalyticsUseCase = MockSendAnalyticsUseCase();
    togglePushNotificationsStatusUseCase =
        MockTogglePushNotificationsStatusUseCase();
    ratingDialogManager = MockRatingDialogManager();
    appManager = MockAppManager();
    localNotificationsService = MockLocalNotificationsService();
    remoteNotificationsService = MockRemoteNotificationsService();
    discoveryFeedManager = MockDiscoveryFeedManager();
    getUserIdUseCase = MockGetUserIdUseCase();
    areLocalNotificationsAllowedUseCase =
        MockAreLocalNotificationsAllowedUseCase();

    di.allowReassignment = true;
    di.registerLazySingleton<SendAnalyticsUseCase>(() => SendAnalyticsUseCase(
          MockAnalyticsService(),
          MockMarketingAnalyticsService(),
        ));
    di.registerLazySingleton<UrlOpener>(() => urlOpener);

    when(listenAppThemeUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );

    when(getAppVersionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(appVersion));

    when(getAppThemeUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(appTheme));

    when(getSubscriptionStatusUseCase.singleOutput(any))
        .thenAnswer((_) => Future.value(subscriptionStatus));

    when(getUserIdUseCase.singleOutput(any))
        .thenAnswer((_) => Future.value(userId));

    when(listenSubscriptionStatusUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(subscriptionStatus));

    when(listenSubscriptionStatusUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);

    when(featureManager.isPaymentEnabled).thenReturn(false);

    when(featureManager.isTopicsEnabled).thenReturn(false);

    when(featureManager.areLocalNotificationsEnabled).thenReturn(false);

    when(featureManager.areRemoteNotificationsEnabled).thenReturn(false);

    when(getSubscriptionManagementUrlUseCase.singleOutput(none)).thenAnswer(
      (_) => Future.value(
          GetSubscriptionManagementUrlOutput(subscriptionManagementURL)),
    );

    when(areLocalNotificationsAllowedUseCase.singleOutput(any))
        .thenAnswer((_) => Future.value(false));

    when(remoteNotificationsService.userNotificationsEnabled)
        .thenAnswer((_) => Future.value(false));
  });

  SettingsScreenManager create() => SettingsScreenManager(
        getAppVersionUseCase,
        getAppThemeUseCase,
        saveAppThemeUseCase,
        listenAppThemeUseCase,
        bugReportingService,
        extractLogUseCase,
        MockSettingsNavActions(),
        shareUriUseCase,
        hapticFeedbackMediumUseCase,
        featureManager,
        getSubscriptionStatusUseCase,
        listenSubscriptionStatusUseCase,
        getSubscriptionManagementUrlUseCase,
        sendAnalyticsUseCase,
        togglePushNotificationsStatusUseCase,
        appManager,
        ratingDialogManager,
        localNotificationsService,
        remoteNotificationsService,
        discoveryFeedManager,
        getUserIdUseCase,
        areLocalNotificationsAllowedUseCase,
      );
  blocTest<SettingsScreenManager, SettingsScreenState>(
    'WHEN manager just created THEN get default values and emit state Ready',
    build: () => create(),
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
        getAppVersionUseCase.singleOutput(none),
        getAppThemeUseCase.singleOutput(none),
        getSubscriptionStatusUseCase.singleOutput(any),
        listenAppThemeUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(saveAppThemeUseCase);
      verifyNoMoreInteractions(getAppVersionUseCase);
      verifyNoMoreInteractions(getAppThemeUseCase);
      verifyNoMoreInteractions(getSubscriptionStatusUseCase);
      verifyNoMoreInteractions(listenAppThemeUseCase);
    },
  );

  blocTest<SettingsScreenManager, SettingsScreenState>(
    'GIVEN app theme WHEN changeTheme method called THEN call saveTheme useCase',
    setUp: () {
      when(saveAppThemeUseCase.call(appTheme)).thenAnswer(
        (_) async => const [UseCaseResult.success(none)],
      );
    },
    build: () => create(),
    act: (manager) => manager.saveTheme(appTheme),
    //default one, emitted when manager created
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
        getAppVersionUseCase.singleOutput(none),
        // this placed here inside, cos it will be called exactly after
        saveAppThemeUseCase.call(AppTheme.dark),
        getAppThemeUseCase.singleOutput(none),
        listenAppThemeUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(saveAppThemeUseCase);
      verifyNoMoreInteractions(getAppVersionUseCase);
      verifyNoMoreInteractions(getAppThemeUseCase);
      verifyNoMoreInteractions(listenAppThemeUseCase);
    },
  );

  blocTest<SettingsScreenManager, SettingsScreenState>(
    'WHEN extractLog method called THEN call ExtractLogUseCase',
    setUp: () => when(extractLogUseCase.call(none)).thenAnswer(
      (_) async => const [
        UseCaseResult.success(
          ExtractLogUseCaseResult.shareDialogOpened,
        ),
      ],
    ),
    build: () => create(),
    act: (manager) => manager.extractLogs(),
    //default one, emitted when manager created
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
        getAppVersionUseCase.singleOutput(none),
        extractLogUseCase.call(none),
        getAppThemeUseCase.singleOutput(none),
        listenAppThemeUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(extractLogUseCase);
      verifyNoMoreInteractions(saveAppThemeUseCase);
      verifyNoMoreInteractions(getAppVersionUseCase);
      verifyNoMoreInteractions(getAppThemeUseCase);
      verifyNoMoreInteractions(listenAppThemeUseCase);
    },
  );

  blocTest<SettingsScreenManager, SettingsScreenState>(
    'WHEN shareApp method called THEN call shareUriUseCase',
    build: () => create(),
    act: (manager) => manager.shareApp(),
    //default one, emitted when manager created
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
        getAppVersionUseCase.singleOutput(none),
        shareUriUseCase.call(Uri.parse(Constants.downloadUrl)),
        getAppThemeUseCase.singleOutput(none),
        listenAppThemeUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(saveAppThemeUseCase);
      verifyNoMoreInteractions(getAppVersionUseCase);
      verifyNoMoreInteractions(getAppThemeUseCase);
      verifyNoMoreInteractions(listenAppThemeUseCase);
      verifyNoMoreInteractions(shareUriUseCase);
    },
  );
  test(
    'GIVEN url string WHEN openUrl method called THEN no exception happened',
    () {
      const url = 'https://xayn.com';

      final manager = create();

      expect(
        () => manager.openExternalUrl(
          url: url,
          currentView: CurrentView.settings,
        ),
        returnsNormally,
      );
      verify(urlOpener.openUrl(url));
      verifyNoMoreInteractions(urlOpener);
    },
  );

  blocTest<SettingsScreenManager, SettingsScreenState>(
    'GIVEN string with url WHEN openUrl method called THEN call ___ useCase',
    build: () => create(),
    act: (manager) => manager.openExternalUrl(
      url: 'https://xayn.com',
      currentView: CurrentView.settings,
    ),
    //default one, emitted when manager created
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
        //default calls here,
        getAppVersionUseCase.singleOutput(none),
        getAppThemeUseCase.singleOutput(none),
        listenAppThemeUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(saveAppThemeUseCase);
      verifyNoMoreInteractions(getAppVersionUseCase);
      verifyNoMoreInteractions(getAppThemeUseCase);
      verifyNoMoreInteractions(listenAppThemeUseCase);
    },
  );
  blocTest<SettingsScreenManager, SettingsScreenState>(
    'INVOKE showDialog for bug reporting THEN call bug Reporting Service',
    setUp: () {
      when(bugReportingService.reportBug()).thenAnswer((_) async {});
    },
    build: () => create(),
    act: (manager) => manager.reportBug(),
    //default one, emitted when manager created
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
        getAppVersionUseCase.singleOutput(none),
        bugReportingService.reportBug(
          brightness: R.brightness,
          primaryColor: R.colors.primaryAction,
        ),
        getAppThemeUseCase.singleOutput(none),
        listenAppThemeUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(saveAppThemeUseCase);
      verifyNoMoreInteractions(getAppVersionUseCase);
      verifyNoMoreInteractions(getAppThemeUseCase);
      verifyNoMoreInteractions(listenAppThemeUseCase);
      verifyNoMoreInteractions(bugReportingService);
    },
  );

  test(
    'GIVEN subscription cancel is tapped THEN analytics event is sent',
    () async {
      when(sendAnalyticsUseCase.call(any)).thenAnswer(
        (_) async => [
          UseCaseResult.success(
            SubscriptionActionEvent(
              action: SubscriptionAction.unsubscribe,
            ),
          ),
        ],
      );
      final manager = create();
      await manager.onSubscriptionLinkCancelTapped();

      verifyInOrder([
        sendAnalyticsUseCase.call(any),
        urlOpener.openUrl(subscriptionManagementURL),
      ]);
      verifyNoMoreInteractions(sendAnalyticsUseCase);
      verifyNoMoreInteractions(urlOpener);
    },
  );

  test(
    'GIVEN push notification switch is tapped THEN call togglePushNotificationsStatusUseCase',
    () async {
      when(togglePushNotificationsStatusUseCase.call(any)).thenAnswer(
        (_) async => [const UseCaseResult.success(none)],
      );
      final manager = create();
      manager.togglePushNotificationsState();

      verify([
        togglePushNotificationsStatusUseCase.call(any),
      ]);
      verifyNoMoreInteractions(togglePushNotificationsStatusUseCase);
    },
  );
}
