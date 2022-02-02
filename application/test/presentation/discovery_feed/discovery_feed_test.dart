import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/feed_repository.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/bing_call_endpoint_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import '../test_utils/dependency_overrides.dart';
import '../test_utils/utils.dart';
import 'discovery_feed_test.mocks.dart';

/// todo: will need to be rewritten once we get rid of all the "fake" engine things,
/// requestFeed and requestNextFeedBatch will be covered when we move away from
/// the temporary test mixins.
@GenerateMocks([
  AppDiscoveryEngine,
  InvokeBingUseCase,
  ConnectivityUseCase,
  FeedRepository,
  AnalyticsService,
])
void main() async {
  late AppDiscoveryEngine engine;
  late MockDiscoveryEngine mockDiscoveryEngine;
  late MockFeedRepository feedRepository;
  late MockInvokeBingUseCase invokeApiEndpointUseCase;
  late MockConnectivityUseCase connectivityUseCase;
  late DiscoveryFeedManager manager;

  createFakeDocument() => Document(
        documentId: DocumentId(),
        feedback: DocumentFeedback.neutral,
        webResource: WebResource(
          displayUrl: Uri.parse('https://displayUrl.test.xayn.com'),
          snippet: 'snippet',
          title: 'title',
          url: Uri.parse('https://url.test.xayn.com'),
          datePublished: DateTime.parse("2021-01-01 00:00:00.000Z"),
          provider: const WebResourceProvider(
            name: "provider",
            thumbnail: null,
          ),
        ),
        nonPersonalizedRank: 0,
        personalizedRank: 0,
        isActive: true,
      );

  final fakeDocumentA = createFakeDocument();
  final fakeDocumentB = createFakeDocument();

  setUp(() async {
    connectivityUseCase = MockConnectivityUseCase();
    mockDiscoveryEngine = MockDiscoveryEngine();
    engine = AppDiscoveryEngine.test(TestDiscoveryEngine());
    invokeApiEndpointUseCase = MockInvokeBingUseCase();
    feedRepository = MockFeedRepository();

    when(feedRepository.get()).thenAnswer((_) => Feed(
          id: const UniqueId.fromTrustedString('test_feed'),
          cardIndex: 0,
        ));
    when(connectivityUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(connectivityUseCase.transaction(any)).thenAnswer(
        (invocation) => Stream.value(invocation.positionalArguments.first));
    when(invokeApiEndpointUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(invokeApiEndpointUseCase.transaction(any)).thenAnswer((_) =>
        Stream.value(
            ApiEndpointResponse.complete([fakeDocumentA, fakeDocumentB])));

    await configureTestDependencies();

    di.registerSingletonAsync<ConnectivityUseCase>(
        () => Future.value(connectivityUseCase));
    di.registerSingleton<InvokeApiEndpointUseCase>(invokeApiEndpointUseCase);
    di.registerSingleton<FeedRepository>(feedRepository);
    di.registerLazySingleton<AnalyticsService>(() => MockAnalyticsService());

    manager = di.get<DiscoveryFeedManager>();
  });

  tearDown(() async {
    await engine.dispose();
    await manager.close();
  });

  blocTest<DiscoveryFeedManager, DiscoveryFeedState>(
    'WHEN feed card index changes THEN store the new index in the repository ',
    build: () => manager,
    setUp: () async {
      di.registerSingleton<DiscoveryEngine>(engine);

      // wait for requestFeed to complete
      await manager.stream.firstWhere((it) => it.results.isNotEmpty);
    },
    act: (manager) async {
      manager.handleIndexChanged(1);
    },
    expect: () => [
      DiscoveryFeedState(
        results: {fakeDocumentA, fakeDocumentB},
        cardIndex: 1,
        isComplete: true,
        isFullScreen: false,
        isInErrorState: false,
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

  blocTest<DiscoveryFeedManager, DiscoveryFeedState>(
    'WHEN closing documents THEN the discovery engine is notified ',
    build: () => manager,
    setUp: () async {
      when(mockDiscoveryEngine.engineEvents)
          .thenAnswer((_) => const Stream.empty());
      when(mockDiscoveryEngine.closeFeedDocuments(any)).thenAnswer(
          (documentIds) => Future.value(const ClientEventSucceeded()));

      di.registerSingleton<DiscoveryEngine>(
          AppDiscoveryEngine.test(mockDiscoveryEngine));

      // wait for requestFeed to complete
      await manager.stream.firstWhere((it) => it.results.isNotEmpty);
    },
    act: (manager) async {
      manager.closeFeedDocuments({fakeDocumentA.documentId});
    },
    verify: (manager) {
      verifyInOrder([
        mockDiscoveryEngine.engineEvents,
        mockDiscoveryEngine.closeFeedDocuments({fakeDocumentA.documentId}),
      ]);
      verifyNoMoreInteractions(mockDiscoveryEngine);
    },
  );

  blocTest<DiscoveryFeedManager, DiscoveryFeedState>(
      'WHEN observing documents THEN the discovery engine is notified ',
      build: () => manager,
      setUp: () async {
        when(mockDiscoveryEngine.engineEvents)
            .thenAnswer((_) => const Stream.empty());
        when(mockDiscoveryEngine.logDocumentTime(
          documentId: anyNamed('documentId'),
          mode: anyNamed('mode'),
          seconds: anyNamed('seconds'),
        )).thenAnswer((_) => Future.value(const ClientEventSucceeded()));

        di.registerSingleton<DiscoveryEngine>(
            AppDiscoveryEngine.test(mockDiscoveryEngine));

        // wait for requestFeed to complete
        await manager.stream.firstWhere((it) => it.results.isNotEmpty);
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
          mockDiscoveryEngine.logDocumentTime(
            documentId: fakeDocumentA.documentId,
            mode: DocumentViewMode.story,
            seconds: 1,
          ),
        ]);
        verifyNoMoreInteractions(mockDiscoveryEngine);
      });

  blocTest<DiscoveryFeedManager, DiscoveryFeedState>(
    'WHEN toggling navigate into card or out of card THEN expect isFullScreen to be updated ',
    build: () => manager,
    setUp: () async {
      when(mockDiscoveryEngine.engineEvents)
          .thenAnswer((_) => const Stream.empty());

      di.registerSingleton<DiscoveryEngine>(
          AppDiscoveryEngine.test(mockDiscoveryEngine));

      // wait for requestFeed to complete
      await manager.stream.firstWhere((it) => it.results.isNotEmpty);
    },
    act: (manager) async {
      manager.handleNavigateIntoCard();
    },
    expect: () => [
      DiscoveryFeedState(
        results: {fakeDocumentA, fakeDocumentB},
        cardIndex: 0,
        isComplete: true,
        isFullScreen: true,
        isInErrorState: false,
      ),
    ],
    verify: (manager) {
      verify(mockDiscoveryEngine.engineEvents);
      verifyNoMoreInteractions(mockDiscoveryEngine);
    },
  );
}
