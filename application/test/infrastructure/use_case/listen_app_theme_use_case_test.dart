import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';

import 'listen_app_theme_use_case_test.mocks.dart';

@GenerateMocks([FakeAppThemeStorage])
void main() {
  late MockFakeAppThemeStorage storage;
  late ListenAppThemeUseCase useCase;
  setUp(() {
    storage = MockFakeAppThemeStorage();
    useCase = ListenAppThemeUseCase(storage);

    when(storage.value).thenAnswer((_) => AppTheme.dark);
  });
  useCaseTest<ListenAppThemeUseCase, None, AppTheme>(
    'WHEN storage emit new value THEN useCase emit it as well',
    build: () => useCase,
    input: [none],
    expect: [useCaseSuccess(AppTheme.dark)],
  );
}
