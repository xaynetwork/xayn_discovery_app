import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/use_case_extension.dart';

import 'listen_app_theme_use_case_test.mocks.dart';

@GenerateMocks([FakeAppThemeStorage])
void main() {
  late MockFakeAppThemeStorage storage;
  late ListenAppThemeUseCase useCase;
  late StreamController<AppTheme> controller;
  setUp(() {
    storage = MockFakeAppThemeStorage();
    controller = StreamController();
    useCase = ListenAppThemeUseCase(storage, controller);
  });
  useCaseTest<ListenAppThemeUseCase, None, AppTheme>(
    'WHEN storage emit new value THEN useCase emit it as well',
    build: () => useCase,
    setUp: () {
      controller.add(AppTheme.dark);
      controller.close();
    },
    input: [none],
    expect: [useCaseSuccess(AppTheme.dark)],
  );
}
