import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';

import 'settings_manager_test.mocks.dart';

@GenerateMocks([
  GetAppVersionUseCase,
  GetAppThemeUseCase,
  SaveAppThemeUseCase,
  ListenAppThemeUseCase,
  BugReportingService,
  ExtractLogUseCase,
  SettingsNavActions,
])
void main() {
  const appVersion = AppVersion(version: '1.2.3', build: '321');
  const appTheme = AppTheme.dark;
  const stateReady = SettingsScreenState.ready(
    theme: appTheme,
    appVersion: appVersion,
  );

  late MockGetAppVersionUseCase getAppVersionUseCase;
  late MockGetAppThemeUseCase getAppThemeUseCase;
  late MockSaveAppThemeUseCase saveAppThemeUseCase;
  late MockListenAppThemeUseCase listenAppThemeUseCase;
  late MockBugReportingService bugReportingService;
  late MockExtractLogUseCase extractLogUseCase;

  setUp(() {
    getAppVersionUseCase = MockGetAppVersionUseCase();
    getAppThemeUseCase = MockGetAppThemeUseCase();
    saveAppThemeUseCase = MockSaveAppThemeUseCase();
    listenAppThemeUseCase = MockListenAppThemeUseCase();
    bugReportingService = MockBugReportingService();
    extractLogUseCase = MockExtractLogUseCase();

    when(listenAppThemeUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );

    when(getAppVersionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(appVersion));

    when(getAppThemeUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(appTheme));
  });

  SettingsScreenManager create() => SettingsScreenManager(
        getAppVersionUseCase,
        getAppThemeUseCase,
        saveAppThemeUseCase,
        listenAppThemeUseCase,
        bugReportingService,
        extractLogUseCase,
        MockSettingsNavActions(),
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
    'WHEN shareApp method called THEN call ___ useCase',
    build: () => create(),
    act: (manager) => manager.shareApp(),
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
  test(
    'GIVEN url string WHEN openUrl method called THEN no exception happened',
    () {
      const url = 'https://xayn.com';

      final manager = create();

      expect(
        () => manager.openUrl(url),
        returnsNormally,
      );
    },
  );
  test(
    'GIVEN NON url string  WHEN openUrl method called THEN throw AssertError',
    () {
      const fakeUrls = [
        'xayn.com',
        'hello',
      ];
      final manager = create();
      for (final fakeUrl in fakeUrls) {
        expect(
          () => manager.openUrl(fakeUrl),
          throwsA(isA<AssertionError>()),
        );
      }
    },
  );
  blocTest<SettingsScreenManager, SettingsScreenState>(
    'GIVEN string with url WHEN openUrl method called THEN call ___ useCase',
    build: () => create(),
    act: (manager) => manager.openUrl('https://xayn.com'),
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
    act: (manager) => manager.reportBug(
      brightness: R.brightness,
      primaryColor: R.colors.primary,
    ),
    //default one, emitted when manager created
    expect: () => [stateReady],
    verify: (manager) {
      verifyInOrder([
        getAppVersionUseCase.singleOutput(none),
        bugReportingService.showDialog(
          brightness: R.brightness,
          primaryColor: R.colors.primary,
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
