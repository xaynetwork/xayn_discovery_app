import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';

import 'listen_app_theme_use_case_test.mocks.dart';

@GenerateMocks([AppSettingsRepository])
void main() {
  late MockAppSettingsRepository repository;
  late ListenAppThemeUseCase useCase;
  setUp(() {
    repository = MockAppSettingsRepository();
    useCase = ListenAppThemeUseCase(repository);

    final settingsWithDarkTheme =
        AppSettings.initial().copyWith(appTheme: AppTheme.dark);
    when(repository.settings).thenAnswer((_) => settingsWithDarkTheme);
    when(repository.watch()).thenAnswer(
      (_) => Stream.value(
        ChangedEvent(
          newObject: settingsWithDarkTheme,
          id: settingsWithDarkTheme.id,
        ),
      ),
    );
  });
  useCaseTest<ListenAppThemeUseCase, None, AppTheme>(
    'WHEN repository emit new value THEN useCase emit it as well',
    build: () => useCase,
    input: [none],
    expect: [useCaseSuccess(AppTheme.dark)],
  );
}
