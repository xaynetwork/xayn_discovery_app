import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockListenAppThemeUseCase listenAppThemeUseCase;
  late MockGetAppThemeUseCase getAppThemeUseCase;
  late MockIncrementAppSessionUseCase incrementAppSessionUseCase;
  late MockCreateOrGetDefaultCollectionUseCase
      createOrGetDefaultCollectionUseCase;
  late Collection mockDefaultCollection;
  late MockCreateDefaultCollectionUseCase createDefaultCollectionUseCase;

  setUp(() {
    mockDefaultCollection =
        Collection.readLater(name: 'mock default collection');
    listenAppThemeUseCase = MockListenAppThemeUseCase();
    getAppThemeUseCase = MockGetAppThemeUseCase();
    incrementAppSessionUseCase = MockIncrementAppSessionUseCase();
    createOrGetDefaultCollectionUseCase =
        MockCreateOrGetDefaultCollectionUseCase();
    createDefaultCollectionUseCase = MockCreateDefaultCollectionUseCase();

    when(getAppThemeUseCase.singleOutput(none)).thenAnswer(
      (_) async => AppTheme.system,
    );
    when(incrementAppSessionUseCase.call(none)).thenAnswer(
      (_) async => const [
        UseCaseResult.success(none),
      ],
    );
    when(getAppThemeUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(listenAppThemeUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(createOrGetDefaultCollectionUseCase.call(any)).thenAnswer(
      (_) async => [
        UseCaseResult.success(mockDefaultCollection),
      ],
    );
    when(createDefaultCollectionUseCase.singleOutput('Read Later')).thenAnswer(
      (_) => Future.value(
        Collection.readLater(name: 'Read Later'),
      ),
    );
  });

  AppManager create() => AppManager(
        getAppThemeUseCase,
        listenAppThemeUseCase,
        incrementAppSessionUseCase,
        createOrGetDefaultCollectionUseCase,
        createDefaultCollectionUseCase,
      );

  blocTest<AppManager, AppState>(
    'GIVEN manager WHEN it is created THEN verify appTheme received',
    build: create,
    expect: () => const [AppState(appTheme: AppTheme.system)],
    verify: (manager) {
      verify(incrementAppSessionUseCase.call(none)).called(1);
      verify(createOrGetDefaultCollectionUseCase.call(any)).called(1);
      verify(getAppThemeUseCase.singleOutput(none)).called(1);
      verify(createDefaultCollectionUseCase.singleOutput('Read Later'))
          .called(1);
      verifyNoMoreInteractions(getAppThemeUseCase);
      verifyNoMoreInteractions(incrementAppSessionUseCase);
      verifyNoMoreInteractions(createDefaultCollectionUseCase);
    },
  );
}
