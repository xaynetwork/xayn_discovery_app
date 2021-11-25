import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/use_case_extension.dart';

import 'get_app_theme_use_case_test.mocks.dart';

@GenerateMocks([FakeAppThemeStorage])
void main() {
  late MockFakeAppThemeStorage storage;
  late GetAppThemeUseCase useCase;
  setUp(() {
    storage = MockFakeAppThemeStorage();
    useCase = GetAppThemeUseCase(storage);
    when(storage.value).thenReturn(AppTheme.system);
  });
  test(
    'WHEN call useCase as Future THEN verify correct return',
    () async {
      final result = (await useCase.call(none)).singleValue;

      expect(result, AppTheme.system);
      verify(storage.value);
      verifyNoMoreInteractions(storage);
    },
  );
}
