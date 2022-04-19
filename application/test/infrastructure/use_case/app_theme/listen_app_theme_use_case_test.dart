import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';

import '../../../test_utils/widget_test_utils.dart';

void main() {
  late HiveAppSettingsRepository repository;
  late ListenAppThemeUseCase useCase;

  final settingsWithDarkTheme =
      AppSettings.initial().copyWith(appTheme: AppTheme.dark);
  final settingsWithLightTheme =
      AppSettings.initial().copyWith(appTheme: AppTheme.light);

  setUp(() async {
    await setupWidgetTest();
    repository = di.get<HiveAppSettingsRepository>();
    useCase = ListenAppThemeUseCase(repository);
  });

  useCaseTest<ListenAppThemeUseCase, None, AppTheme>(
    'WHEN repository emit single value THEN useCase emit it as well',
    setUp: () {
      repository.save(settingsWithDarkTheme);
    },
    build: () => useCase,
    input: [none],
    expect: [useCaseSuccess(AppTheme.dark)],
  );

  useCaseTest<ListenAppThemeUseCase, None, AppTheme>(
    'WHEN repository emit multiple values THEN useCase emit them as well',
    act: () {
      repository.save(settingsWithDarkTheme);
      repository.save(settingsWithLightTheme);
    },
    build: () => useCase,
    input: [none],
    expect: [
      useCaseSuccess(AppTheme.dark),
      useCaseSuccess(AppTheme.light),
    ],
  );
}
