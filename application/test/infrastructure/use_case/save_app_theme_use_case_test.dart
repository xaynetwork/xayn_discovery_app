import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';

import 'save_app_theme_use_case_test.mocks.dart';

@GenerateMocks([AppSettingsRepository])
void main() {
  late MockAppSettingsRepository repository;
  late SaveAppThemeUseCase useCase;

  const appTheme = AppTheme.dark;

  setUp(() {
    repository = MockAppSettingsRepository();
    useCase = SaveAppThemeUseCase(repository);
    when(repository.settings).thenAnswer((_) => AppSettings.initial());
  });

  test(
    'GIVEN appTheme to store WHEN call useCase as Future THEN update value in repository',
    () async {
      await useCase.call(appTheme);

      verifyInOrder([
        repository.settings,
        repository.settings =
            AppSettings.initial().copyWith(appTheme: appTheme),
      ]);
      verifyNoMoreInteractions(repository);
    },
  );
}
