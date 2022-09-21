import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart'
    as item_renderer;
import 'package:xayn_discovery_app/domain/model/feed/feed.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
// import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/session/session.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/feed_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notification/push_notifications_card_injection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/survey_banner/survey_card_injection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/mark_onboarding_type_completed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/need_to_show_onboarding_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/listen_push_notifications_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/toggle_push_notifications_state_use_case.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import '../../test_utils/dependency_overrides.dart';
import '../../test_utils/utils.dart';
import '../../test_utils/widget_test_utils.dart';

/// todo: will need to be rewritten once we get rid of all the "fake" engine things,
/// requestFeed and requestNextFeedBatch will be covered when we move away from
/// the temporary test mixins.

void main() async {
  late AppDiscoveryEngine engine;
  late MockOverlayManager<DiscoveryState> overlayManager;
  late MockFeatureManager featureManager;
  late MockAppDiscoveryEngine mockDiscoveryEngine;
  late MockFeedRepository feedRepository;
  late MockAreMarketsOutdatedUseCase areMarketsOutdatedUseCase;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockFetchSessionUseCase fetchSessionUseCase;
  late MockNeedToShowOnboardingUseCase needToShowOnboardingUseCase;
  late MockMarkOnboardingTypeCompletedUseCase
      markOnboardingTypeCompletedUseCase;
  late MockSurveyCardInjectionUseCase surveyCardInjectionUseCase;
  late MockPushNotificationsCardInjectionUseCase
      pushNotificationsCardInjectionUseCase;
  late MockListenPushNotificationsStatusUseCase
      listenPushNotificationsStatusUseCase;
  late DiscoveryFeedManager manager;
  late StreamController<EngineEvent> eventsController;
  final subscriptionStatusInitial = SubscriptionStatus.initial();

  createFakeDocument() => Document(
        documentId: DocumentId(),
        resource: NewsResource(
          image: Uri.parse('https://displayUrl.test.xayn.com'),
          sourceDomain: Source('example'),
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
        userReaction: UserReaction.neutral,
        stackId: StackId.nil(),
      );

  final fakeDocumentA = createFakeDocument();
  final fakeDocumentB = createFakeDocument();
  final fakeDocumentC = createFakeDocument();
  final fakeDocumentD = createFakeDocument();

  setUp(() async {
    eventsController = StreamController<EngineEvent>();
    overlayManager = MockOverlayManager();
    featureManager = MockFeatureManager();
    areMarketsOutdatedUseCase = MockAreMarketsOutdatedUseCase();
    getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
    fetchSessionUseCase = MockFetchSessionUseCase();
    mockDiscoveryEngine = MockAppDiscoveryEngine();
    needToShowOnboardingUseCase = MockNeedToShowOnboardingUseCase();
    surveyCardInjectionUseCase = MockSurveyCardInjectionUseCase();
    pushNotificationsCardInjectionUseCase =
        MockPushNotificationsCardInjectionUseCase();
    listenPushNotificationsStatusUseCase =
        MockListenPushNotificationsStatusUseCase();
    markOnboardingTypeCompletedUseCase =
        MockMarkOnboardingTypeCompletedUseCase();
    engine = AppDiscoveryEngine.test(TestDiscoveryEngine());
    feedRepository = MockFeedRepository();

    setupWidgetTest();

    when(feedRepository.get()).thenAnswer((_) => Feed(
          id: const UniqueId.fromTrustedString('test_feed'),
          cardIndexFeed: 0,
          cardIndexSearch: 0,
        ));
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
    when(surveyCardInjectionUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(surveyCardInjectionUseCase.transaction(any))
        .thenAnswer((realInvocation) {
      final Set<Document> documents = realInvocation.positionalArguments.first;

      return Stream.value(documents.map(item_renderer.Card.document).toSet());
    });
    when(surveyCardInjectionUseCase.singleOutput(any)).thenAnswer(
        (realInvocation) async => surveyCardInjectionUseCase
            .toCards((realInvocation.positionalArguments.first
                    as SurveyCardInjectionData)
                .nextDocuments)
            .toSet());
    when(surveyCardInjectionUseCase.toCards(any)).thenAnswer((realInvocation) =>
        (realInvocation.positionalArguments.first as Set<Document>? ?? const {})
            .map(item_renderer.Card.document));
    when(pushNotificationsCardInjectionUseCase.singleOutput(any))
        .thenAnswer((realInvocation) async {
      final cards = (realInvocation.positionalArguments.first
              as PushNotificationsCardInjectionData)
          .currentCards;
      return cards;
    });

    when(listenPushNotificationsStatusUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(listenPushNotificationsStatusUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(false));

    when(featureManager.isOnBoardingSheetsEnabled)
        .thenAnswer((realInvocation) => true);
    when(featureManager.isPaymentEnabled).thenAnswer((realInvocation) => false);

    di.reset();

    await configureTestDependencies();

    di.registerSingleton<DiscoveryEngine>(mockDiscoveryEngine);
    di.registerSingleton<FeedRepository>(feedRepository);
    di.registerSingleton<FeatureManager>(featureManager);
    di.registerLazySingleton<AnalyticsService>(() => MockAnalyticsService());
    di.registerLazySingleton<GetSubscriptionStatusUseCase>(
        () => getSubscriptionStatusUseCase);
    di.registerSingleton<FetchSessionUseCase>(fetchSessionUseCase);
    di.registerSingleton<NeedToShowOnboardingUseCase>(
        needToShowOnboardingUseCase);
    di.registerSingleton<MarkOnboardingTypeCompletedUseCase>(
        markOnboardingTypeCompletedUseCase);
    di.registerSingleton<SurveyCardInjectionUseCase>(
        surveyCardInjectionUseCase);
    di.registerSingleton<PushNotificationsCardInjectionUseCase>(
        pushNotificationsCardInjectionUseCase);
    di.registerLazySingleton<TogglePushNotificationsStatusUseCase>(
        () => MockTogglePushNotificationsStatusUseCase());
    di.registerLazySingleton<ListenPushNotificationsStatusUseCase>(
        () => listenPushNotificationsStatusUseCase);

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
      await manager.stream.firstWhere((it) => it.cards.isNotEmpty);
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

/* 
  TODO: Enable this test once the inline card manager is ready

  blocTest<DiscoveryFeedManager, DiscoveryState>(
    'WHEN feed card index changes THEN store the new index in the repository ',
    build: () => manager,
    setUp: () async {
      when(fetchSessionUseCase.singleOutput(none))
          .thenAnswer((_) async => Session.withFeedRequested());
      // wait for requestFeed to complete
      await manager.stream.firstWhere((it) => it.cards.isNotEmpty);
    },
    act: (manager) async => manager.handleIndexChanged(1),
    expect: () => [
      DiscoveryState(
        cards: {
          item_renderer.Card.document(fakeDocumentA),
          item_renderer.Card.document(fakeDocumentB),
        },
        cardIndex: 1,
        isComplete: true,
        isFullScreen: false,
        didReachEnd: false,
        subscriptionStatus: null,
      ),
    ],
    verify: (manager) {
      verifyInOrder([
        // when manager inits
        feedRepository.get(),
        // request feed mixin
        feedRepository.get(),
        // check value just before save
        feedRepository.get(),
        feedRepository.save(any),
      ]);
      verifyNoMoreInteractions(feedRepository);
    },
  );
*/

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

      // wait for requestFeed to complete
      await manager.stream.firstWhere((it) => it.cards.isNotEmpty);
    },
    act: (manager) async {
      manager.closeFeedDocuments({fakeDocumentA.documentId});
    },
    verify: (manager) {
      verifyInOrder([
        mockDiscoveryEngine.restoreFeed(),
        // after restore, old user index in feed is 0, so other cards are now closed
        mockDiscoveryEngine.closeFeedDocuments({fakeDocumentB.documentId}),
        mockDiscoveryEngine.restoreFeed(),
        mockDiscoveryEngine.engineEvents,
        mockDiscoveryEngine.requestNextFeedBatch(),
        // the close from the act handler
        mockDiscoveryEngine.closeFeedDocuments({fakeDocumentA.documentId}),
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
          mockDiscoveryEngine.restoreFeed(),
          mockDiscoveryEngine.closeFeedDocuments({fakeDocumentB.documentId}),
          mockDiscoveryEngine.restoreFeed(),
          mockDiscoveryEngine.engineEvents,
          mockDiscoveryEngine.requestNextFeedBatch(),
        ]);
        verifyNoMoreInteractions(mockDiscoveryEngine);
      });

/*
TODO: Enable this test once the inline card manager is ready

  blocTest<DiscoveryFeedManager, DiscoveryState>(
    'WHEN toggling navigate into card or out of card THEN expect isFullScreen to be updated ',
    build: () => manager,
    setUp: () => when(fetchSessionUseCase.singleOutput(none))
        .thenAnswer((_) async => Session.withFeedRequested()),
    act: (manager) async {
      manager.handleNavigateIntoCard(fakeDocumentA);
    },
    verify: (manager) {
      expect(
        manager.state,
        DiscoveryState(
          cards: {
            item_renderer.Card.document(fakeDocumentA),
            item_renderer.Card.document(fakeDocumentB),
          },
          cardIndex: 0,
          isComplete: false,
          isFullScreen: true,
          shouldUpdateNavBar: false,
          didReachEnd: false,
          subscriptionStatus: subscriptionStatusInitial,
          readerModeBackgroundColor: ReaderModeBackgroundColor(
            dark: ReaderModeBackgroundDarkColor.dark,
            light: ReaderModeBackgroundLightColor.white,
          ),
        ),
      );
      verifyInOrder([
        mockDiscoveryEngine.restoreFeed(),
        mockDiscoveryEngine.closeFeedDocuments({fakeDocumentB.documentId}),
        mockDiscoveryEngine.restoreFeed(),
        mockDiscoveryEngine.engineEvents,
        mockDiscoveryEngine.requestNextFeedBatch(),
      ]);
      verifyNoMoreInteractions(mockDiscoveryEngine);
    },
  );
  */

  group('test onboarding', () {
    setUp(() {
      manager.setOverlayManager(overlayManager);
      when(fetchSessionUseCase.singleOutput(none))
          .thenAnswer((_) async => Session.start());
    });

    blocTest<DiscoveryFeedManager, DiscoveryState>(
      'GIVEN true WHEN _needToShowOnboardingUseCase is called THEN overlayManager.show called',
      build: () => manager,
      setUp: () {
        when(needToShowOnboardingUseCase
                .singleOutput(OnboardingType.homeVerticalSwipe))
            .thenAnswer((_) async => true);
      },
      act: (manager) => manager.checkIfNeedToShowOnboarding(),
      verify: (manager) {
        // return;
        verifyInOrder([
          featureManager.isOnBoardingSheetsEnabled,
          needToShowOnboardingUseCase
              .singleOutput(OnboardingType.homeVerticalSwipe),
          overlayManager.show(any),
          overlayManager.onNewState(any),
        ]);
        verifyNoMoreInteractions(needToShowOnboardingUseCase);
        verifyNoMoreInteractions(manager.overlayManager);
      },
    );

    blocTest<DiscoveryFeedManager, DiscoveryState>(
      'GIVEN true WHEN _needToShowOnboardingUseCase is called THEN overlayManager.show called',
      build: () => manager,
      setUp: () {
        when(needToShowOnboardingUseCase
                .singleOutput(OnboardingType.homeVerticalSwipe))
            .thenAnswer((_) async => false);
        when(needToShowOnboardingUseCase
                .singleOutput(OnboardingType.homeHorizontalSwipe))
            .thenAnswer((_) async => true);
      },
      act: (manager) => manager.checkIfNeedToShowOnboarding(),
      verify: (manager) {
        // return;
        verifyInOrder([
          needToShowOnboardingUseCase
              .singleOutput(OnboardingType.homeVerticalSwipe),
          needToShowOnboardingUseCase
              .singleOutput(OnboardingType.homeHorizontalSwipe),
          overlayManager.show(any),
          overlayManager.onNewState(any),
        ]);
        verifyNoMoreInteractions(needToShowOnboardingUseCase);
        verifyNoMoreInteractions(manager.overlayManager);
      },
    );

    blocTest<DiscoveryFeedManager, DiscoveryState>(
      'GIVEN true WHEN _needToShowOnboardingUseCase is called THEN overlayManager.show called',
      build: () => manager,
      setUp: () {
        when(needToShowOnboardingUseCase
                .singleOutput(OnboardingType.homeVerticalSwipe))
            .thenAnswer((_) async => false);
        when(needToShowOnboardingUseCase
                .singleOutput(OnboardingType.homeHorizontalSwipe))
            .thenAnswer((_) async => false);
        when(needToShowOnboardingUseCase
                .singleOutput(OnboardingType.homeBookmarksManage))
            .thenAnswer((_) async => true);
      },
      act: (manager) => manager.checkIfNeedToShowOnboarding(),
      verify: (manager) {
        // return;
        verifyInOrder([
          needToShowOnboardingUseCase
              .singleOutput(OnboardingType.homeVerticalSwipe),
          needToShowOnboardingUseCase
              .singleOutput(OnboardingType.homeHorizontalSwipe),
          needToShowOnboardingUseCase
              .singleOutput(OnboardingType.homeBookmarksManage),
          overlayManager.show(any),
          overlayManager.onNewState(any),
        ]);
        verifyNoMoreInteractions(needToShowOnboardingUseCase);
        verifyNoMoreInteractions(manager.overlayManager);
      },
    );

    blocTest<DiscoveryFeedManager, DiscoveryState>(
      'GIVEN false WHEN _needToShowOnboardingUseCase is called THEN overlayManager.show called',
      build: () => manager,
      setUp: () {
        when(needToShowOnboardingUseCase
                .singleOutput(OnboardingType.homeVerticalSwipe))
            .thenAnswer((_) async => false);
        when(needToShowOnboardingUseCase
                .singleOutput(OnboardingType.homeHorizontalSwipe))
            .thenAnswer((_) async => false);
        when(needToShowOnboardingUseCase
                .singleOutput(OnboardingType.homeBookmarksManage))
            .thenAnswer((_) async => false);
      },
      act: (manager) => manager.checkIfNeedToShowOnboarding(),
      verify: (manager) {
        verifyInOrder([
          featureManager.isOnBoardingSheetsEnabled,
          needToShowOnboardingUseCase
              .singleOutput(OnboardingType.homeVerticalSwipe),
          needToShowOnboardingUseCase
              .singleOutput(OnboardingType.homeHorizontalSwipe),
          needToShowOnboardingUseCase
              .singleOutput(OnboardingType.homeBookmarksManage),
        ]);
        verifyNoMoreInteractions(needToShowOnboardingUseCase);
        verifyZeroInteractions(manager.overlayManager);
      },
    );
  });
}
