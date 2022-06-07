import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_document_filter_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/apply_document_filter_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/crud_document_filter_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/save_user_interaction_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/document_filter/manager/document_filter_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/document_filter/manager/document_filter_state.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import '../../../test_utils/fakes.dart';
import '../../../test_utils/utils.dart';
import '../../../test_utils/widget_test_utils.dart';

main() {
  late DocumentFilterManager manager;
  final filter =
      DocumentFilter.fromSource(fakeDocument.resource.sourceDomain.value);
  late DiscoveryEngine engine;
  late HiveDocumentFilterRepository repository;
  late SaveUserInteractionUseCase saveUserInteractionUseCase;
  late MockUserInteractionsRepository userInteractionsRepository;
  late MockFeatureManager featureManager;
  late MockIsSurveyBannerFeatureActiveUseCase
      isSurveyBannerFeatureActiveUseCase;
  setUp(() async {
    await setupWidgetTest();
    repository = di.get();
    final documentFilterUseCase = CrudDocumentFilterUseCase(repository);
    userInteractionsRepository = MockUserInteractionsRepository();
    isSurveyBannerFeatureActiveUseCase =
        MockIsSurveyBannerFeatureActiveUseCase();
    featureManager = MockFeatureManager();
    saveUserInteractionUseCase = SaveUserInteractionUseCase(
      userInteractionsRepository,
      isSurveyBannerFeatureActiveUseCase,
    );
    engine = di.get<DiscoveryEngine>();
    final applyDocumentFilterUseCase =
        ApplyDocumentFilterUseCase(repository, engine);
    manager = DocumentFilterManager(
      documentFilterUseCase,
      applyDocumentFilterUseCase,
      saveUserInteractionUseCase,
      fakeDocument,
    );

    when(isSurveyBannerFeatureActiveUseCase.singleOutput(none))
        .thenAnswer((_) async => Future.value(true));
    when(featureManager.isPromptSurveyEnabled).thenReturn(true);
  });

  blocTest<DocumentFilterManager, DocumentFilterState>(
    'WHEN manager just created THEN emit state with document filter not selected',
    build: () => manager,
    expect: () => [
      DocumentFilterState(
        filters: {
          filter: false,
        },
        hasPendingChanges: false,
      )
    ],
  );

  blocTest<DocumentFilterManager, DocumentFilterState>(
    'WHEN togging the filter, state has pending changed and filter is active',
    build: () => manager,
    act: (m) => m.onFilterTogglePressed(filter),
    skip: 1,
    expect: () => [
      DocumentFilterState(
        filters: {
          filter: true,
        },
        hasPendingChanges: true,
      )
    ],
  );

  blocTest<DocumentFilterManager, DocumentFilterState>(
      'WHEN togging the filter, the value is not stored yet.',
      build: () => manager,
      act: (m) => m.onFilterTogglePressed(filter),
      verify: (m) {
        expect(repository.getAll(), isEmpty);
      });

  blocTest<DocumentFilterManager, DocumentFilterState>(
      'WHEN togging the filter, and applying it, then value should be stored and send to the engine.',
      build: () => manager,
      setUp: () => when(userInteractionsRepository.userInteractions).thenReturn(
            UserInteractions.initial(),
          ),
      act: (m) {
        m.onFilterTogglePressed(filter);
        m.onApplyChangesPressed();
      },
      verify: (m) async {
        expect(repository.getAll(), [filter]);
        expect(
            await engine.getExcludedSourcesList(),
            EngineEvent.excludedSourcesListRequestSucceeded(
                {Source(filter.filterValue)}));
      });

  blocTest<DocumentFilterManager, DocumentFilterState>(
      'WHEN togging the filter another time, and applying it, then value should be removed from db and engine.',
      build: () => manager,
      setUp: () => when(userInteractionsRepository.userInteractions).thenReturn(
            UserInteractions.initial(),
          ),
      act: (m) async {
        m.onFilterTogglePressed(filter);
        await m.onApplyChangesPressed();
        m.onFilterTogglePressed(filter);
        await m.onApplyChangesPressed();
      },
      verify: (m) async {
        expect(repository.getAll(), isEmpty);
        expect(await engine.getExcludedSourcesList(),
            const EngineEvent.excludedSourcesListRequestSucceeded({}));
      });
}
