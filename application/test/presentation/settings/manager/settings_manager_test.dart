import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';

import '../../test_utils/utils.dart';

void main() {
  const appVersion = AppVersion(version: '1.2.3', build: '321');
  const appTheme = AppTheme.dark;
  const stateReady = SettingsScreenState.ready(
    theme: appTheme,
    appVersion: appVersion,
    isPaymentEnabled: false,
    trialEndDate: null,
  );

  late MockFeatureManager featureManager;
  late MockGetAppVersionUseCase getAppVersionUseCase;
  late MockGetAppThemeUseCase getAppThemeUseCase;
  late MockSaveAppThemeUseCase saveAppThemeUseCase;
  late MockListenAppThemeUseCase listenAppThemeUseCase;

  setUp(() {
    featureManager = MockFeatureManager();
    getAppVersionUseCase = MockGetAppVersionUseCase();
    getAppThemeUseCase = MockGetAppThemeUseCase();
    saveAppThemeUseCase = MockSaveAppThemeUseCase();
    listenAppThemeUseCase = MockListenAppThemeUseCase();

    di.allowReassignment = true;
    di.registerLazySingleton<SendAnalyticsUseCase>(
        () => SendAnalyticsUseCase(MockAnalyticsService()));

    when(listenAppThemeUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );

    when(getAppVersionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(appVersion));

    when(getAppThemeUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(appTheme));

    when(featureManager.isPaymentEnabled).thenReturn(false);
  });

  SettingsScreenManager create() => SettingsScreenManager(
        getAppVersionUseCase,
        getAppThemeUseCase,
        saveAppThemeUseCase,
        listenAppThemeUseCase,
        MockSettingsNavActions(),
        featureManager,
      );
  blocTest<SettingsScreenManager, SettingsScreenState>(
    'WHEN manager just created THEN get default values and emit state Ready',
    build: () => create(),
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
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
}
