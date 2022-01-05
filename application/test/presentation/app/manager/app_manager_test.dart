import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';

import '../../utils/utils.dart';

void main() {
  late MockListenAppThemeUseCase listenAppThemeUseCase;
  late MockGetAppThemeUseCase getAppThemeUseCase;
  setUp(() {
    listenAppThemeUseCase = MockListenAppThemeUseCase();
    getAppThemeUseCase = MockGetAppThemeUseCase();

    when(getAppThemeUseCase.singleOutput(none)).thenAnswer(
      (_) async => AppTheme.system,
    );
    when(getAppThemeUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(listenAppThemeUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );
  });

  AppManager create() => AppManager(
        getAppThemeUseCase,
        listenAppThemeUseCase,
      );

  blocTest<AppManager, AppState>(
    'GIVEN manager WHEN it is created THEN verify appTheme received',
    build: create,
    expect: () => const [AppState(appTheme: AppTheme.system)],
    verify: (manager) {
      verify(getAppThemeUseCase.singleOutput(none)).called(1);
      verifyNoMoreInteractions(getAppThemeUseCase);
    },
  );
}
