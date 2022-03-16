import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockListenAppThemeUseCase listenAppThemeUseCase;
  late MockIncrementAppSessionUseCase incrementAppSessionUseCase;
  late MockCreateOrGetDefaultCollectionUseCase
      createOrGetDefaultCollectionUseCase;
  late MockAppSettingsRepository appSettingsRepository;
  late MockRenameDefaultCollectionUseCase renameDefaultCollectionUseCase;
  late Collection mockDefaultCollection;

  setUp(() {
    mockDefaultCollection =
        Collection.readLater(name: 'mock default collection');
    listenAppThemeUseCase = MockListenAppThemeUseCase();
    incrementAppSessionUseCase = MockIncrementAppSessionUseCase();
    createOrGetDefaultCollectionUseCase =
        MockCreateOrGetDefaultCollectionUseCase();
    renameDefaultCollectionUseCase = MockRenameDefaultCollectionUseCase();
    appSettingsRepository = MockAppSettingsRepository();

    when(appSettingsRepository.settings).thenReturn(AppSettings.initial());

    when(incrementAppSessionUseCase.call(none)).thenAnswer(
      (_) async => const [
        UseCaseResult.success(none),
      ],
    );
    when(listenAppThemeUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(createOrGetDefaultCollectionUseCase.call(any)).thenAnswer(
      (_) async => [
        UseCaseResult.success(mockDefaultCollection),
      ],
    );
  });

  AppManager create() => AppManager(
        listenAppThemeUseCase,
        incrementAppSessionUseCase,
        createOrGetDefaultCollectionUseCase,
        renameDefaultCollectionUseCase,
        appSettingsRepository,
      );

  blocTest<AppManager, AppState>(
    'GIVEN manager WHEN it is created THEN verify appTheme received',
    build: create,
    expect: () => const [AppState(appTheme: AppTheme.system)],
    verify: (manager) {
      verify(appSettingsRepository.settings).called(1);
      verify(incrementAppSessionUseCase.call(none)).called(1);
      verify(createOrGetDefaultCollectionUseCase
              .call(R.strings.defaultCollectionNameReadLater))
          .called(1);
      verifyNoMoreInteractions(incrementAppSessionUseCase);
    },
  );

  blocTest<AppManager, AppState>(
    'WHEN maybeUpdateDefaultCollectionName is called THEN call the useCase',
    build: create,
    act: (manager) => manager.maybeUpdateDefaultCollectionName(),
    verify: (manager) {
      verify(
        renameDefaultCollectionUseCase.call(
          R.strings.defaultCollectionNameReadLater,
        ),
      ).called(1);

      verifyNoMoreInteractions(renameDefaultCollectionUseCase);
    },
  );
}
