import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';

import 'save_app_theme_use_case_test.mocks.dart';

@GenerateMocks([FakeAppThemeStorage])
void main() {
  late MockFakeAppThemeStorage storage;
  late SaveAppThemeUseCase useCase;

  const appTheme = AppTheme.dark;

  setUp(() {
    storage = MockFakeAppThemeStorage();
    useCase = SaveAppThemeUseCase(storage);
  });

  test(
    'GIVEN appTheme to store WHEN call useCase as Future THEN update value in storage',
    () async {
      await useCase.call(appTheme);

      verify(storage.value = appTheme);
      verifyNoMoreInteractions(storage);
    },
  );
}
