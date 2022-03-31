import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/session/session.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/feed_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import '../test_utils/dependency_overrides.dart';
import '../test_utils/utils.dart';
import '../test_utils/widget_test_utils.dart';
import 'discovery_feed_test.mocks.dart';

/// todo: will need to be rewritten once we get rid of all the "fake" engine things,
/// requestFeed and requestNextFeedBatch will be covered when we move away from
/// the temporary test mixins.
@GenerateMocks([
  ConnectivityUseCase,
  FeedRepository,
])
void main() async {
  late AppDiscoveryEngine engine;
  late MockAppDiscoveryEngine mockDiscoveryEngine;
  late MockFeedRepository feedRepository;
  late MockConnectivityUseCase connectivityUseCase;
  late MockAreMarketsOutdatedUseCase areMarketsOutdatedUseCase;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockFetchSessionUseCase fetchSessionUseCase;
  late DiscoveryFeedManager manager;
  late StreamController<EngineEvent> eventsController;
  final subscriptionStatusInitial = SubscriptionStatus.initial();

  createFakeDocument() => Document(
        documentId: DocumentId(),
        resource: NewsResource(
          image: Uri.parse('https://displayUrl.test.xayn.com'),
          sourceDomain: 'example',
          topic: 'topic',
          score: .0,
          rank: -1,
          language: 'en-US',
          country: 'US',
          snippet: 'snippet',
          title: 'title',
          url: Uri.parse('https://url.test.xayn.com'),
          datePublished: DateTime.parse("2021-01-01 00:00:00.000Z"),
        ),
        batchIndex: -1,
        userReaction: UserReaction.neutral,
      );

  final fakeDocumentA = createFakeDocument();
  final fakeDocumentB = createFakeDocument();
  final fakeDocumentC = createFakeDocument();
  final fakeDocumentD = createFakeDocument();

  setUp(() async {
    eventsController = StreamController<EngineEvent>();
    connectivityUseCase = MockConnectivityUseCase();
    areMarketsOutdatedUseCase = MockAreMarketsOutdatedUseCase();
    getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
    fetchSessionUseCase = MockFetchSessionUseCase();
    mockDiscoveryEngine = MockAppDiscoveryEngine();
    engine = AppDiscoveryEngine.test(TestDiscoveryEngine());
    feedRepository = MockFeedRepository();

    setupWidgetTest();

    when(feedRepository.get()).thenAnswer((_) => Feed(
          id: const UniqueId.fromTrustedString('test_feed'),
          cardIndexFeed: 0,
          cardIndexSearch: 0,
        ));
    when(connectivityUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(connectivityUseCase.transaction(any)).thenAnswer(
        (invocation) => Stream.value(invocation.positionalArguments.first));
    when(mockDiscoveryEngine.engineEvents)
        .thenAnswer((_) => eventsController.stream);
    when(areMarketsOutdatedUseCase.transaction(FeedType.feed))
        .thenAnswer((_) => Stream.value(false));
    when(mockDiscoveryEngine.restoreFeed()).thenAnswer((_) {
      final event = RestoreFeedSucceeded([fakeDocumentA, fakeDocumentB]);

      eventsController.add(event);

      return Future.value(event);
    });
    when(mockDiscoveryEngine.closeFeedDocuments(any))
        .thenAnswer((_) async => const EngineEvent.clientEventSucceeded());
    when(getSubscriptionStatusUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(getSubscriptionStatusUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(subscriptionStatusInitial));
    when(mockDiscoveryEngine.requestNextFeedBatch()).thenAnswer(
        (realInvocation) async => EngineEvent.nextFeedBatchRequestSucceeded([
              fakeDocumentC,
              fakeDocumentD,
            ]));

    await configureTestDependencies();

    di.registerSingleton<DiscoveryEngine>(mockDiscoveryEngine);
    di.registerSingletonAsync<ConnectivityUseCase>(
        () => Future.value(connectivityUseCase));
    di.registerSingleton<FeedRepository>(feedRepository);
    di.registerLazySingleton<AnalyticsService>(() => MockAnalyticsService());
    di.registerLazySingleton<GetSubscriptionStatusUseCase>(
        () => getSubscriptionStatusUseCase);
    di.registerSingleton<FetchSessionUseCase>(fetchSessionUseCase);

    manager = di.get<DiscoveryFeedManager>();
  });

  tearDown(() async {
    await eventsController.close();
    await engine.dispose();
    await manager.close();
  });

  blocTest<DiscoveryFeedManager, DiscoveryState>(
    'WHEN feed loads THEN verify call stack - first render after startup version ',
    build: () => manager,
    setUp: () async {
      when(fetchSessionUseCase.singleOutput(none))
          .thenAnswer((_) async => Session.start());
      // wait for requestFeed to complete
      await manager.stream.firstWhere((it) => it.results.isNotEmpty);
    },
    verify: (manager) {
      verifyInOrder([
        mockDiscoveryEngine.restoreFeed(),
        mockDiscoveryEngine.closeFeedDocuments(any),
        mockDiscoveryEngine.restoreFeed(),
        mockDiscoveryEngine.engineEvents,
        mockDiscoveryEngine.requestNextFeedBatch(),
      ]);
      verifyNoMoreInteractions(mockDiscoveryEngine);
    },
  );

  blocTest<DiscoveryFeedManager, DiscoveryState>(
    'WHEN feed loads THEN verify call stack - non-first render after startup version ',
    build: () => manager,
    setUp: () async {
      when(fetchSessionUseCase.singleOutput(none))
          .thenAnswer((_) async => Session.withFeedRequested());
      // wait for requestFeed to complete
      await manager.stream.firstWhere((it) => it.results.isNotEmpty);
    },
    verify: (manager) {
      verifyInOrder([
        mockDiscoveryEngine.engineEvents,
        mockDiscoveryEngine.restoreFeed(),
        mockDiscoveryEngine.requestNextFeedBatch(),
      ]);
      verifyNoMoreInteractions(mockDiscoveryEngine);
    },
  );

  blocTest<DiscoveryFeedManager, DiscoveryState>(
    'WHEN feed card index changes THEN store the new index in the repository ',
    build: () => manager,
    setUp: () async {
      when(fetchSessionUseCase.singleOutput(none))
          .thenAnswer((_) async => Session.withFeedRequested());
      // wait for requestFeed to complete
      await manager.stream.firstWhere((it) => it.results.isNotEmpty);
    },
    act: (manager) async {
      manager.handleIndexChanged(1);
    },
    expect: () => [
      DiscoveryState(
        results: {fakeDocumentA, fakeDocumentB},
        cardIndex: 1,
        isComplete: false,
        isFullScreen: false,
        isInErrorState: false,
        didReachEnd: false,
        subscriptionStatus: subscriptionStatusInitial,
      ),
    ],
    verify: (manager) {
      verifyInOrder([
        // when manager inits
        feedRepository.get(),
        // check value just before save
        feedRepository.get(),
        feedRepository.save(any),
      ]);
      verifyNoMoreInteractions(feedRepository);
    },
  );

  blocTest<DiscoveryFeedManager, DiscoveryState>(
    'WHEN closing documents THEN the discovery engine is notified ',
    build: () => manager,
    setUp: () async {
      when(fetchSessionUseCase.singleOutput(none))
          .thenAnswer((_) async => Session.withFeedRequested());

      when(mockDiscoveryEngine.closeFeedDocuments(any))
          .thenAnswer((documentIds) async {
        const event = ClientEventSucceeded();

        eventsController.add(event);

        return event;
      });
    },
    act: (manager) async {
      manager.closeFeedDocuments({fakeDocumentA.documentId});
    },
    verify: (manager) {
      verifyInOrder([
        mockDiscoveryEngine.closeFeedDocuments({fakeDocumentA.documentId}),
        mockDiscoveryEngine.engineEvents,
        mockDiscoveryEngine.restoreFeed(),
        mockDiscoveryEngine.requestNextFeedBatch(),
      ]);
      verifyNoMoreInteractions(mockDiscoveryEngine);
    },
  );

  blocTest<DiscoveryFeedManager, DiscoveryState>(
      'WHEN observing documents THEN the discovery engine is notified ',
      build: () => manager,
      setUp: () async {
        when(fetchSessionUseCase.singleOutput(none))
            .thenAnswer((_) async => Session.withFeedRequested());

        when(mockDiscoveryEngine.logDocumentTime(
          documentId: anyNamed('documentId'),
          mode: anyNamed('mode'),
          seconds: anyNamed('seconds'),
        )).thenAnswer((_) async {
          const event = ClientEventSucceeded();

          eventsController.add(event);

          return event;
        });
      },
      act: (manager) async {
        manager.observeDocument(
          document: fakeDocumentA,
          mode: DocumentViewMode.story,
        );
        await Future.delayed(const Duration(milliseconds: 1500));
        manager.observeDocument(
          document: fakeDocumentA,
          mode: DocumentViewMode.reader,
        );
      },
      verify: (manager) {
        verifyInOrder([
          mockDiscoveryEngine.engineEvents,
          mockDiscoveryEngine.restoreFeed(),
          mockDiscoveryEngine.requestNextFeedBatch(),
          mockDiscoveryEngine.logDocumentTime(
            documentId: fakeDocumentA.documentId,
            mode: DocumentViewMode.story,
            seconds: 1,
          ),
        ]);
        verifyNoMoreInteractions(mockDiscoveryEngine);
      });

  blocTest<DiscoveryFeedManager, DiscoveryState>(
    'WHEN toggling navigate into card or out of card THEN expect isFullScreen to be updated ',
    build: () => manager,
    setUp: () => when(fetchSessionUseCase.singleOutput(none))
        .thenAnswer((_) async => Session.withFeedRequested()),
    act: (manager) async {
      manager.handleNavigateIntoCard(fakeDocumentA);
    },
    expect: () => [
      DiscoveryState(
        results: {fakeDocumentA, fakeDocumentB},
        cardIndex: 0,
        isComplete: false,
        isFullScreen: true,
        isInErrorState: false,
        shouldUpdateNavBar: true,
        didReachEnd: false,
        subscriptionStatus: subscriptionStatusInitial,
      ),
    ],
    verify: (manager) {
      verify(mockDiscoveryEngine.engineEvents);
      verify(mockDiscoveryEngine.restoreFeed());
      verify(mockDiscoveryEngine.requestNextFeedBatch());
      verifyNoMoreInteractions(mockDiscoveryEngine);
    },
  );
}
