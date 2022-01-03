import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

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
