import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
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
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/custom_card/push_notifications_card_injection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/custom_card/survey_card_injection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/listen_push_notifications_conditions_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/listen_survey_conditions_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/save_user_interaction_use_case.dart';
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
  late MockListenSurveyConditionsStatusUseCase
      listenSurveyConditionsStatusUseCase;
  late MockListenPushNotificationsConditionsStatusUseCase
      listenPushNotificationsConditionsStatusUseCase;
  late MockHandleSurveyBannerClickedUseCase handleSurveyBannerClickedUseCase;
  late MockHandleSurveyBannerShownUseCase handleSurveyBannerShownUseCase;
  late MockSurveyCardInjectionUseCase surveyCardInjectionUseCase;
  late MockPushNotificationsCardInjectionUseCase
      pushNotificationsCardInjectionUseCase;
  late MockHandlePushNotificationsCardClickedUseCase
      handlePushNotificationsCardClickedUseCase;
  late MockFeatureManager featureManager;
  late MockUserInteractionsRepository userInteractionsRepository;
  late MockCanDisplaySurveyBannerUseCase canDisplaySurveyBannerUseCase;
  late MockCanDisplayPushNotificationsCardUseCase
      canDisplayPushNotificationsCardUseCase;
  final subscriptionStatusInitial = SubscriptionStatus.initial();

  setUp(() async {
    await setupWidgetTest();
    engine = MockAppDiscoveryEngine();
    areMarketsOutdatedUseCase = MockAreMarketsOutdatedUseCase();
    getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
    listenReaderModeSettingsUseCase = MockListenReaderModeSettingsUseCase();
    listenSurveyConditionsStatusUseCase =
        MockListenSurveyConditionsStatusUseCase();
    listenPushNotificationsConditionsStatusUseCase =
        MockListenPushNotificationsConditionsStatusUseCase();
    handleSurveyBannerClickedUseCase = MockHandleSurveyBannerClickedUseCase();
    handleSurveyBannerShownUseCase = MockHandleSurveyBannerShownUseCase();
    surveyCardInjectionUseCase = MockSurveyCardInjectionUseCase();
    pushNotificationsCardInjectionUseCase =
        MockPushNotificationsCardInjectionUseCase();
    handlePushNotificationsCardClickedUseCase =
        MockHandlePushNotificationsCardClickedUseCase();
    userInteractionsRepository = MockUserInteractionsRepository();
    featureManager = MockFeatureManager();
    canDisplaySurveyBannerUseCase = MockCanDisplaySurveyBannerUseCase();
    canDisplayPushNotificationsCardUseCase =
        MockCanDisplayPushNotificationsCardUseCase();

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
    when(surveyCardInjectionUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(surveyCardInjectionUseCase.transaction(any))
        .thenAnswer((realInvocation) {
      final Set<Document> documents = realInvocation.positionalArguments.first;

      return Stream.value(documents.map(Card.document).toSet());
    });
    when(listenSurveyConditionsStatusUseCase.transaction(any)).thenAnswer(
        (realInvocation) => Stream.value(SurveyConditionsStatus.notReached));
    when(listenSurveyConditionsStatusUseCase.transform(any)).thenAnswer(
        (realInvocation) =>
            realInvocation.positionalArguments.first as Stream<None>);
    when(listenPushNotificationsConditionsStatusUseCase.transaction(any))
        .thenAnswer((realInvocation) =>
            Stream.value(PushNotificationsConditionsStatus.notReached));
    when(listenPushNotificationsConditionsStatusUseCase.transform(any))
        .thenAnswer((realInvocation) =>
            realInvocation.positionalArguments.first as Stream<None>);
    when(surveyCardInjectionUseCase.singleOutput(any)).thenAnswer(
        (realInvocation) async => surveyCardInjectionUseCase
            .toCards((realInvocation.positionalArguments.first
                    as SurveyCardInjectionData)
                .nextDocuments)
            .toSet());
    when(surveyCardInjectionUseCase.toCards(any)).thenAnswer((realInvocation) =>
        (realInvocation.positionalArguments.first as Set<Document>? ?? const {})
            .map(Card.document));
    when(pushNotificationsCardInjectionUseCase.singleOutput(any)).thenAnswer(
        (realInvocation) async => pushNotificationsCardInjectionUseCase
            .toCards((realInvocation.positionalArguments.first
                    as PushNotificationsCardInjectionData)
                .currentCards)
            .toSet());
    when(pushNotificationsCardInjectionUseCase.toCards(any)).thenAnswer(
        (realInvocation) =>
            (realInvocation.positionalArguments.first as Iterable<Card>? ??
                const {}));

    buildManager = () => ActiveSearchManager(
          MockActiveSearchNavActions(),
          EngineEventsUseCase(engine),
          FetchCardIndexUseCase(feedRepository),
          UpdateCardIndexUseCase(feedRepository),
          SendAnalyticsUseCase(
            AnalyticsServiceDebugMode(),
            MarketingAnalyticsServiceDebugMode(),
          ),
          CrudExplicitDocumentFeedbackUseCase(
            HiveExplicitDocumentFeedbackRepository(
              ExplicitDocumentFeedbackMapper(),
            ),
          ),
          HapticFeedbackMediumUseCase(),
          getSubscriptionStatusUseCase,
          listenReaderModeSettingsUseCase,
          listenSurveyConditionsStatusUseCase,
          listenPushNotificationsConditionsStatusUseCase,
          handleSurveyBannerClickedUseCase,
          handleSurveyBannerShownUseCase,
          surveyCardInjectionUseCase,
          pushNotificationsCardInjectionUseCase,
          handlePushNotificationsCardClickedUseCase,
          featureManager,
          CardManagersCache(),
          SaveUserInteractionUseCase(
            userInteractionsRepository,
            canDisplaySurveyBannerUseCase,
            canDisplayPushNotificationsCardUseCase,
          ),
        );
  });

  blocTest<ActiveSearchManager, DiscoveryState>(
    'GIVEN fresh manager THEN the state is DiscoveryFeedState.initial()',
    build: () {
      when(engine.engineEvents).thenAnswer((_) => const Stream.empty());
      when(areMarketsOutdatedUseCase.singleOutput(FeedType.search))
          .thenAnswer((_) async => false);
      when(engine.restoreActiveSearch()).thenAnswer(
        (_) async => RestoreActiveSearchSucceeded(
          const ActiveSearch(
            searchTerm: '',
            searchBy: SearchBy.query,
          ),
          [fakeDocument],
        ),
      );
      when(engine.getActiveSearchTerm()).thenAnswer(
          (_) async => const EngineEvent.activeSearchTermRequestSucceeded(''));
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
      final restoreEvent = RestoreActiveSearchSucceeded(
        const ActiveSearch(
          searchTerm: '',
          searchBy: SearchBy.query,
        ),
        [fakeDocument],
      );

      when(engine.engineEvents).thenAnswer((_) => Stream.value(restoreEvent));
      when(areMarketsOutdatedUseCase.singleOutput(FeedType.search))
          .thenAnswer((_) async => false);
      when(engine.restoreActiveSearch()).thenAnswer(
        (_) async => restoreEvent,
      );
      when(engine.getActiveSearchTerm()).thenAnswer(
          (_) async => const EngineEvent.activeSearchTermRequestSucceeded(''));
      when(featureManager.isPaymentEnabled).thenReturn(false);
      return buildManager();
    },
    verify: (bloc) {
      expect(bloc.state.isComplete, isTrue);
      expect(bloc.state.cards, isNotEmpty);
    },
  );
}
