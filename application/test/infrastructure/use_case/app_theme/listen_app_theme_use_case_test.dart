import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockAppSettingsRepository repository;
  late ListenAppThemeUseCase useCase;

  final settingsWithDarkTheme =
      AppSettings.initial().copyWith(appTheme: AppTheme.dark);
  final settingsWithLightTheme =
      AppSettings.initial().copyWith(appTheme: AppTheme.light);

  setUp(() {
    repository = MockAppSettingsRepository();
    useCase = ListenAppThemeUseCase(repository);

    when(repository.settings).thenAnswer((_) => settingsWithDarkTheme);
  });

  useCaseTest<ListenAppThemeUseCase, None, AppTheme>(
    'WHEN repository emit single value THEN useCase emit it as well',
    setUp: () {
      when(repository.watch()).thenAnswer(
        (_) => Stream.value(
          ChangedEvent(
            newObject: settingsWithDarkTheme,
            id: settingsWithDarkTheme.id,
          ),
        ),
      );
    },
    build: () => useCase,
    input: [none],
    expect: [useCaseSuccess(AppTheme.dark)],
  );

  useCaseTest<ListenAppThemeUseCase, None, AppTheme>(
    'WHEN repository emit multiple values THEN useCase emit them as well',
    setUp: () {
      when(repository.watch()).thenAnswer(
        (_) => Stream.fromIterable([
          ChangedEvent(
            newObject: settingsWithDarkTheme,
            id: settingsWithDarkTheme.id,
          ),
          ChangedEvent(
            newObject: settingsWithLightTheme,
            id: settingsWithLightTheme.id,
          ),
        ]),
      );
    },
    build: () => useCase,
    input: [none],
    expect: [
      useCaseSuccess(AppTheme.dark),
      useCaseSuccess(AppTheme.light),
    ],
  );
}
