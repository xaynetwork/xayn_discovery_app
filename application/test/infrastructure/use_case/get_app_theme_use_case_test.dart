import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';

import 'get_app_theme_use_case_test.mocks.dart';

@GenerateMocks([AppSettingsRepository])
void main() {
  late MockAppSettingsRepository repository;
  late GetAppThemeUseCase useCase;
  setUp(() {
    repository = MockAppSettingsRepository();
    useCase = GetAppThemeUseCase(repository);
    when(repository.settings).thenAnswer((_) => AppSettings.initial());
  });
  test(
    'WHEN call useCase as Future THEN verify correct return',
    () async {
      final result = (await useCase.singleOutput(none));

      expect(result, AppTheme.system);
      verify(repository.settings);
      verifyNoMoreInteractions(repository);
    },
  );
}
