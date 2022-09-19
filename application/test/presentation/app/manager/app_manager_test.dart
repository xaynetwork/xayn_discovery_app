import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';

import '../../../test_utils/widget_test_utils.dart';

class FakeBrightnessProvider implements PlatformBrightnessProvider {
  @override
  Brightness brightness = Brightness.light;
}

void main() {
  late AppManager manager;
  late FakeBrightnessProvider brightnessProvider;
  late AppSettingsRepository appSettingsRepository;

  setUp(() async {
    await setupWidgetTest();
  });

  AppManager _createManager({AppTheme theme = AppTheme.system}) {
    brightnessProvider = FakeBrightnessProvider();
    appSettingsRepository = di.get();
    appSettingsRepository
        .save(appSettingsRepository.settings.copyWith(appTheme: theme));

    manager = AppManager(
      di.get(),
      di.get(),
      di.get(),
      di.get(),
      di.get(),
      di.get(),
      di.get(),
      di.get(),
      di.get(),
      di.get(),
      di.get(),
      appSettingsRepository,
      brightnessProvider,
    );

    return manager;
  }

  test("When the app theme is system, deliver the system brightness", () async {
    _createManager();

    expect(manager.state.brightness, Brightness.light);
  });

  blocTest(
    "When the app theme is system, and we switch the brightness, deliver the system brightness",
    build: () => _createManager(),
    act: (m) {
      brightnessProvider.brightness = Brightness.dark;
      manager.onChangedPlatformBrightness();
    },
    skip: 1,
    expect: () => [
      const AppState(brightness: Brightness.dark, isAppPaused: false),
    ],
  );

  test(
      "When registering a lifecycle callback, call-back when condition is fulfilled",
      () async {
    _createManager();

    int callbackExecuted = 0;
    manager.registerStateTransitionCallback(
        AppTransitionConditions.returnToApp, () => callbackExecuted++);

    manager.onChangeAppLifecycleState(AppLifecycleState.inactive);
    manager.onChangeAppLifecycleState(AppLifecycleState.resumed);

    expect(callbackExecuted, 1);
  });

  test(
      "When registering a lifecycle callback, call-back only once when condition is fulfilled",
      () async {
    _createManager();

    int callbackExecuted = 0;
    manager.registerStateTransitionCallback(
        AppTransitionConditions.returnToApp, () => callbackExecuted++);

    manager.onChangeAppLifecycleState(AppLifecycleState.inactive);
    manager.onChangeAppLifecycleState(AppLifecycleState.resumed);
    callbackExecuted = 0;

    manager.onChangeAppLifecycleState(AppLifecycleState.inactive);
    manager.onChangeAppLifecycleState(AppLifecycleState.resumed);

    expect(callbackExecuted, 0);
  });
}
