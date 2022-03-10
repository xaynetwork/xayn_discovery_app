import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/restore_search_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/explicit_document_feedback_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import '../../presentation/test_utils/fakes.dart';
import '../../presentation/test_utils/utils.dart';
import '../../presentation/test_utils/widget_test_utils.dart';

void main() {
  late ActiveSearchManager Function() buildManager;
  late DiscoveryEngine engine;

  setUp(() async {
    await setupWidgetTest();
    engine = MockDiscoveryEngine();
    di
      ..unregister<DiscoveryEngine>()
      ..registerSingleton<DiscoveryEngine>(engine);

    final feedRepository = HiveFeedRepository(FeedMapper());

    buildManager = () => ActiveSearchManager(
          MockActiveSearchNavActions(),
          RestoreSearchUseCase(engine),
          FetchCardIndexUseCase(feedRepository),
          UpdateCardIndexUseCase(feedRepository),
          SendAnalyticsUseCase(AnalyticsServiceDebugMode()),
          CrudExplicitDocumentFeedbackUseCase(
              HiveExplicitDocumentFeedbackRepository(
                  ExplicitDocumentFeedbackMapper())),
        );
  });

  blocTest<ActiveSearchManager, DiscoveryState>(
    'GIVEN fresh manager THEN the state is DiscoveryFeedState.initial()',
    build: () {
      when(engine.engineEvents).thenAnswer((_) => const Stream.empty());
      when(engine.restoreSearch()).thenAnswer(
        (_) async => RestoreSearchSucceeded(
          const ActiveSearch(
            queryTerm: '',
            market: FeedMarket(
              countryCode: '',
              langCode: '',
            ),
            pageSize: 0,
            requestedPageNb: 0,
          ),
          [fakeDocument],
        ),
      );
      return buildManager();
    },
    expect: () => [DiscoveryState.initial().copyWith(isComplete: true)],
  );

  blocTest<ActiveSearchManager, DiscoveryState>(
    'GIVEN use case emits results THEN the state contains results',
    build: () {
      final restoreEvent = RestoreSearchSucceeded(
        const ActiveSearch(
          queryTerm: '',
          market: FeedMarket(
            countryCode: '',
            langCode: '',
          ),
          pageSize: 0,
          requestedPageNb: 0,
        ),
        [fakeDocument],
      );

      when(engine.engineEvents).thenAnswer((_) => Stream.value(restoreEvent));
      when(engine.restoreSearch()).thenAnswer(
        (_) async => restoreEvent,
      );
      return buildManager();
    },
    verify: (bloc) {
      expect(bloc.state.isComplete, isTrue);
      expect(bloc.state.isInErrorState, isFalse);
      expect(bloc.state.results, isNotEmpty);
    },
  );

  blocTest<ActiveSearchManager, DiscoveryState>(
    'GIVEN use case throws an error THEN the error state is true',
    build: () {
      when(engine.engineEvents).thenAnswer(
        (_) => Stream.value(
          const EngineExceptionRaised(EngineExceptionReason.genericError),
        ),
      );
      return buildManager();
    },
    verify: (bloc) {
      expect(bloc.state.isInErrorState, isTrue);
    },
  );
}
