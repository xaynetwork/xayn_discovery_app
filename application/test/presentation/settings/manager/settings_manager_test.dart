import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';

import '../../test_utils/utils.dart';
import 'settings_manager_test.mocks.dart';

@GenerateMocks([AnalyticsService])
void main() {
  const appVersion = AppVersion(version: '1.2.3', build: '321');
  const appTheme = AppTheme.dark;
  const isTtsEnabled = true;
  final subscriptionStatus = SubscriptionStatus.initial();
  const subscriptionManagementURL = 'https://example.com';
  final stateReady = SettingsScreenState.ready(
    theme: appTheme,
    appVersion: appVersion,
    isTtsEnabled: true,
    isPaymentEnabled: false,
    subscriptionStatus: subscriptionStatus,
    subscriptionManagementURL: subscriptionManagementURL,
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
  late MockGetTtsPreferenceUseCase getTtsPreferenceUseCase;
  late MockSaveTtsPreferenceUseCase saveTtsPreferenceUseCase;
  late MockListenTtsPreferenceUseCase listenTtsPreferenceUseCase;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockListenSubscriptionStatusUseCase listenSubscriptionStatusUseCase;
  late MockHapticFeedbackMediumUseCase hapticFeedbackMediumUseCase;
  late MockGetSubscriptionManagementUrlUseCase
      getSubscriptionManagementUrlUseCase;

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
    getTtsPreferenceUseCase = MockGetTtsPreferenceUseCase();
    saveTtsPreferenceUseCase = MockSaveTtsPreferenceUseCase();
    listenTtsPreferenceUseCase = MockListenTtsPreferenceUseCase();
    getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
    listenSubscriptionStatusUseCase = MockListenSubscriptionStatusUseCase();
    hapticFeedbackMediumUseCase = MockHapticFeedbackMediumUseCase();
    getSubscriptionManagementUrlUseCase =
        MockGetSubscriptionManagementUrlUseCase();

    di.allowReassignment = true;
    di.registerLazySingleton<SendAnalyticsUseCase>(
        () => SendAnalyticsUseCase(MockAnalyticsService()));
    di.registerLazySingleton<UrlOpener>(() => urlOpener);

    when(listenAppThemeUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );

    when(listenTtsPreferenceUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );

    when(getAppVersionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(appVersion));

    when(getAppThemeUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(appTheme));

    when(getTtsPreferenceUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(isTtsEnabled));

    when(getSubscriptionStatusUseCase.singleOutput(PurchasableIds.subscription))
        .thenAnswer((_) => Future.value(subscriptionStatus));

    when(listenSubscriptionStatusUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(subscriptionStatus));

    when(listenSubscriptionStatusUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);

    when(featureManager.isPaymentEnabled).thenReturn(false);

    when(getSubscriptionManagementUrlUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(subscriptionManagementURL));
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
        getTtsPreferenceUseCase,
        saveTtsPreferenceUseCase,
        listenTtsPreferenceUseCase,
        hapticFeedbackMediumUseCase,
        featureManager,
        getSubscriptionStatusUseCase,
        listenSubscriptionStatusUseCase,
        getSubscriptionManagementUrlUseCase,
      );
  blocTest<SettingsScreenManager, SettingsScreenState>(
    'WHEN manager just created THEN get default values and emit state Ready',
    build: () => create(),
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
        getAppVersionUseCase.singleOutput(none),
        getTtsPreferenceUseCase.singleOutput(none),
        getAppThemeUseCase.singleOutput(none),
        getSubscriptionStatusUseCase.singleOutput(any),
        listenAppThemeUseCase.transform(any),
        listenTtsPreferenceUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(saveAppThemeUseCase);
      verifyNoMoreInteractions(saveTtsPreferenceUseCase);
      verifyNoMoreInteractions(getAppVersionUseCase);
      verifyNoMoreInteractions(getAppThemeUseCase);
      verifyNoMoreInteractions(getTtsPreferenceUseCase);
      verifyNoMoreInteractions(getSubscriptionStatusUseCase);
      verifyNoMoreInteractions(listenAppThemeUseCase);
      verifyNoMoreInteractions(listenTtsPreferenceUseCase);
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
    'GIVEN text-to-speech WHEN saveTtsPreference method called THEN call saveTts useCase',
    setUp: () {
      when(saveTtsPreferenceUseCase.call(isTtsEnabled)).thenAnswer(
        (_) async => const [UseCaseResult.success(isTtsEnabled)],
      );
    },
    build: () => create(),
    act: (manager) => manager.saveTextToSpeechPreference(isTtsEnabled),
    //default one, emitted when manager created
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
        getAppVersionUseCase.singleOutput(none),
        // this placed here inside, cos it will be called exactly after
        saveTtsPreferenceUseCase.call(isTtsEnabled),
        getTtsPreferenceUseCase.singleOutput(none),
        listenTtsPreferenceUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(saveTtsPreferenceUseCase);
      verifyNoMoreInteractions(getAppVersionUseCase);
      verifyNoMoreInteractions(getTtsPreferenceUseCase);
      verifyNoMoreInteractions(listenTtsPreferenceUseCase);
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
        () => manager.openExternalUrl(url, CurrentView.settings),
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
      'https://xayn.com',
      CurrentView.settings,
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
      when(bugReportingService.showDialog()).thenAnswer((_) async {});
    },
    build: () => create(),
    act: (manager) => manager.reportBug(),
    //default one, emitted when manager created
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
        getAppVersionUseCase.singleOutput(none),
        bugReportingService.showDialog(
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
}
