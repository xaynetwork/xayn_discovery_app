import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/are_markets_outdated_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/explicit_document_feedback_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/card_managers_cache.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import '../../../test_utils/fakes.dart';
import '../../../test_utils/utils.dart';
import '../../../test_utils/widget_test_utils.dart';

void main() {
  late ActiveSearchManager Function() buildManager;
  late AppDiscoveryEngine engine;
  late MockAreMarketsOutdatedUseCase areMarketsOutdatedUseCase;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockListenReaderModeSettingsUseCase listenReaderModeSettingsUseCase;
  late MockFeatureManager featureManager;
  late MockFetchTrendingTopicsUseCase fetchTrendingTopicsUseCase;
  final subscriptionStatusInitial = SubscriptionStatus.initial();

  setUp(() async {
    await setupWidgetTest();
    engine = MockAppDiscoveryEngine();
    areMarketsOutdatedUseCase = MockAreMarketsOutdatedUseCase();
    getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
    listenReaderModeSettingsUseCase = MockListenReaderModeSettingsUseCase();
    featureManager = MockFeatureManager();
    fetchTrendingTopicsUseCase = MockFetchTrendingTopicsUseCase();

    di
      ..unregister<DiscoveryEngine>()
      ..registerSingleton<DiscoveryEngine>(engine);

    di
      ..unregister<AreMarketsOutdatedUseCase>()
      ..registerSingleton<AreMarketsOutdatedUseCase>(areMarketsOutdatedUseCase);

    final feedRepository = HiveFeedRepository(FeedMapper());

    when(getSubscriptionStatusUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(getSubscriptionStatusUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(subscriptionStatusInitial));
    when(listenReaderModeSettingsUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );

    buildManager = () => ActiveSearchManager(
          MockActiveSearchNavActions(),
          fetchTrendingTopicsUseCase,
          EngineEventsUseCase(engine),
          FetchCardIndexUseCase(feedRepository),
          UpdateCardIndexUseCase(feedRepository),
          SendAnalyticsUseCase(
            AnalyticsServiceDebugMode(),
          ),
          CrudExplicitDocumentFeedbackUseCase(
            HiveExplicitDocumentFeedbackRepository(
              ExplicitDocumentFeedbackMapper(),
            ),
          ),
          HapticFeedbackMediumUseCase(),
          getSubscriptionStatusUseCase,
          listenReaderModeSettingsUseCase,
          featureManager,
          CardManagersCache(),
        );
  });

  blocTest<ActiveSearchManager, DiscoveryState>(
    'GIVEN fresh manager THEN the state is DiscoveryFeedState.initial()',
    build: () {
      when(engine.engineEvents).thenAnswer((_) => const Stream.empty());
      when(areMarketsOutdatedUseCase.singleOutput(FeedType.search))
          .thenAnswer((_) async => false);
      when(engine.restoreSearch()).thenAnswer(
        (_) async => RestoreSearchSucceeded(
          const ActiveSearch(
            queryTerm: '',
            pageSize: 0,
            requestedPageNb: 0,
          ),
          [fakeDocument],
        ),
      );
      when(engine.getSearchTerm()).thenAnswer(
          (_) async => const EngineEvent.searchTermRequestSucceeded(''));
      when(featureManager.isPaymentEnabled).thenReturn(true);
      return buildManager();
    },
    verify: (bloc) => expect(
      bloc.state,
      DiscoveryState.initial().copyWith(
        subscriptionStatus: subscriptionStatusInitial,
      ),
    ),
  );

  blocTest<ActiveSearchManager, DiscoveryState>(
    'GIVEN use case emits results THEN the state contains results',
    build: () {
      final restoreEvent = RestoreSearchSucceeded(
        const ActiveSearch(
          queryTerm: '',
          pageSize: 0,
          requestedPageNb: 0,
        ),
        [fakeDocument],
      );

      when(engine.engineEvents).thenAnswer((_) => Stream.value(restoreEvent));
      when(areMarketsOutdatedUseCase.singleOutput(FeedType.search))
          .thenAnswer((_) async => false);
      when(engine.restoreSearch()).thenAnswer(
        (_) async => restoreEvent,
      );
      when(engine.getSearchTerm()).thenAnswer(
          (_) async => const EngineEvent.searchTermRequestSucceeded(''));
      when(featureManager.isPaymentEnabled).thenReturn(false);
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
      when(engine.restoreSearch()).thenAnswer(
        (_) async =>
            const EngineExceptionRaised(EngineExceptionReason.genericError),
      );
      when(engine.engineEvents).thenAnswer(
        (_) => Stream.value(
          const EngineExceptionRaised(EngineExceptionReason.genericError),
        ),
      );
      when(areMarketsOutdatedUseCase.singleOutput(FeedType.search))
          .thenAnswer((_) async => false);
      when(engine.getSearchTerm()).thenAnswer(
          (_) async => const EngineEvent.searchTermRequestSucceeded(''));
      return buildManager();
    },
    verify: (bloc) {
      expect(bloc.state.isInErrorState, isTrue);
    },
  );
}
