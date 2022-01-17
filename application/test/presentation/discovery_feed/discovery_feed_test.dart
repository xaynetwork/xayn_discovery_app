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

@GenerateMocks([
  AppDiscoveryEngine,
  InvokeBingUseCase,
  ConnectivityUseCase,
  FeedRepository,
  AnalyticsService,
])
void main() async {
  late final AppDiscoveryEngine engine;
  late final MockFeedRepository feedRepository;
  late final MockInvokeBingUseCase invokeApiEndpointUseCase;
  late final MockConnectivityUseCase connectivityUseCase;
  late final DiscoveryFeedManager manager;

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
    engine = AppDiscoveryEngine(TestDiscoveryEngine());
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
    di.registerSingletonAsync<InvokeApiEndpointUseCase>(
        () => Future.value(invokeApiEndpointUseCase));
    di.registerSingletonAsync<DiscoveryEngine>(() => Future.value(engine));
    di.registerSingleton<FeedRepository>(feedRepository);
    di.registerSingleton<AnalyticsService>(MockAnalyticsService());

    manager = await di.getAsync<DiscoveryFeedManager>();
  });

  tearDown(() async {
    await engine.dispose();
    await manager.close();
  });

  blocTest<DiscoveryFeedManager, DiscoveryFeedState>(
    'WHEN feed card index changes THEN store the new index in the repository ',
    build: () => manager,
    setUp: () async {
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
      verify(feedRepository.get()).called(2);
      verify(feedRepository.save(any)).called(1);
      verifyNoMoreInteractions(feedRepository);
    },
  );
}
