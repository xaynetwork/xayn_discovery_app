import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';

import '../../test_utils/utils.dart';

void main() {
  const appTheme = AppTheme.dark;
  const isTtsEnabled = true;
  final subscriptionStatus = SubscriptionStatus.initial();
  final stateReady = SettingsScreenState.ready(
    theme: appTheme,
    isTtsEnabled: true,
    isPaymentEnabled: false,
    subscriptionStatus: subscriptionStatus,
  );

  late MockFeatureManager featureManager;
  late MockGetAppThemeUseCase getAppThemeUseCase;
  late MockSaveAppThemeUseCase saveAppThemeUseCase;
  late MockListenAppThemeUseCase listenAppThemeUseCase;
  late MockGetTtsPreferenceUseCase getTtsPreferenceUseCase;
  late MockSaveTtsPreferenceUseCase saveTtsPreferenceUseCase;
  late MockListenTtsPreferenceUseCase listenTtsPreferenceUseCase;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockListenSubscriptionStatusUseCase listenSubscriptionStatusUseCase;

  setUp(() {
    featureManager = MockFeatureManager();
    getAppThemeUseCase = MockGetAppThemeUseCase();
    saveAppThemeUseCase = MockSaveAppThemeUseCase();
    listenAppThemeUseCase = MockListenAppThemeUseCase();
    getTtsPreferenceUseCase = MockGetTtsPreferenceUseCase();
    saveTtsPreferenceUseCase = MockSaveTtsPreferenceUseCase();
    listenTtsPreferenceUseCase = MockListenTtsPreferenceUseCase();
    getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
    listenSubscriptionStatusUseCase = MockListenSubscriptionStatusUseCase();

    di.allowReassignment = true;
    di.registerLazySingleton<SendAnalyticsUseCase>(
        () => SendAnalyticsUseCase(MockAnalyticsService()));

    when(listenAppThemeUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );

    when(listenTtsPreferenceUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );

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
  });

  SettingsScreenManager create() => SettingsScreenManager(
        getAppThemeUseCase,
        saveAppThemeUseCase,
        listenAppThemeUseCase,
        MockSettingsNavActions(),
        getTtsPreferenceUseCase,
        saveTtsPreferenceUseCase,
        listenTtsPreferenceUseCase,
        featureManager,
        getSubscriptionStatusUseCase,
        listenSubscriptionStatusUseCase,
      );
  blocTest<SettingsScreenManager, SettingsScreenState>(
    'WHEN manager just created THEN get default values and emit state Ready',
    build: () => create(),
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
        getTtsPreferenceUseCase.singleOutput(none),
        getAppThemeUseCase.singleOutput(none),
        getSubscriptionStatusUseCase.singleOutput(any),
        listenAppThemeUseCase.transform(any),
        listenTtsPreferenceUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(saveAppThemeUseCase);
      verifyNoMoreInteractions(saveTtsPreferenceUseCase);
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
        // this placed here inside, cos it will be called exactly after
        saveAppThemeUseCase.call(AppTheme.dark),
        getAppThemeUseCase.singleOutput(none),
        listenAppThemeUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(saveAppThemeUseCase);
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
        // this placed here inside, cos it will be called exactly after
        getTtsPreferenceUseCase.singleOutput(none),
        saveTtsPreferenceUseCase.call(isTtsEnabled),
        listenTtsPreferenceUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(saveTtsPreferenceUseCase);
      verifyNoMoreInteractions(getTtsPreferenceUseCase);
      verifyNoMoreInteractions(listenTtsPreferenceUseCase);
    },
  );
}
