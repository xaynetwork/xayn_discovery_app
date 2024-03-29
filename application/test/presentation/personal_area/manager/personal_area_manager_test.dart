import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/list_item_model.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';

import '../../../test_utils/utils.dart';

void main() {
  late PersonalAreaNavActions actions;
  late MockOverlayManager<PersonalAreaState> overlayManager;
  late MockFeatureManager featureManager;
  late MockGetAllCollectionsUseCase getAllCollectionsUseCase;
  late MockListenCollectionsUseCase listenCollectionsUseCase;
  late MockNeedToShowOnboardingUseCase needToShowOnboardingUseCase;
  late MockMarkOnboardingTypeCompletedUseCase
      markOnboardingTypeCompletedUseCase;
  late MockHapticFeedbackMediumUseCase hapticFeedbackMediumUseCase;
  late MockDateTimeHandler dateTimeHandler;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockListenSubscriptionStatusUseCase listenSubscriptionStatusUseCase;
  late MockUniqueIdHandler uniqueIdHandler;
  final timeStamp = DateTime.now();
  final paymentItemId = UniqueId();
  final subscriptionStatusInitial = SubscriptionStatus.initial();
  final subscriptionStatusFreeTrial = SubscriptionStatus(
    expirationDate: null,
    trialEndDate: DateTime(timeStamp.year, timeStamp.month, timeStamp.day + 7),
    willRenew: false,
    purchaseDate: null,
    isBetaUser: false,
  );

  late UrlOpener urlOpener;
  final collection1 =
      Collection(id: UniqueId(), name: 'Collection1 name', index: 0);
  final collection2 =
      Collection(id: UniqueId(), name: 'Collection2 name', index: 1);
  final contacts = ListItemModel.contact(id: paymentItemId);

  final collectionsList = [
    ListItemModel.collection(
      id: collection1.id,
      collection: collection1,
    ),
    ListItemModel.collection(
      id: collection2.id,
      collection: collection2,
    ),
    contacts,
  ];

  final populatedStateOnlyCollections = PersonalAreaState.populated(
    collectionsList,
  );

  final populatedStateWithTrialBanner = PersonalAreaState.populated(
    [
      ListItemModel.payment(
        id: paymentItemId,
        trialEndDate: subscriptionStatusFreeTrial.trialEndDate!,
      ),
      collectionsList[0],
      collectionsList[1],
      contacts,
    ],
  );

  void _mockManagerInitMethodCalls() {
    when(getAllCollectionsUseCase.singleOutput(none)).thenAnswer(
      (_) => Future.value(
        GetAllCollectionsUseCaseOut(
          [
            collection1,
            collection2,
          ],
        ),
      ),
    );

    when(listenCollectionsUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );

    when(dateTimeHandler.getDateTimeNow()).thenReturn(timeStamp);
    when(uniqueIdHandler.generateUniqueId()).thenReturn(paymentItemId);
    when(getSubscriptionStatusUseCase.singleOutput(any))
        .thenAnswer((_) async => subscriptionStatusInitial);
    when(listenSubscriptionStatusUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(subscriptionStatusInitial));
    when(listenSubscriptionStatusUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(featureManager.isPaymentEnabled).thenReturn(false);
    when(featureManager.isOnBoardingSheetsEnabled)
        .thenAnswer((realInvocation) => true);
  }

  setUp(
    () {
      di.allowReassignment = true;
      di.registerLazySingleton<SendAnalyticsUseCase>(
        () => SendAnalyticsUseCase(
          MockAnalyticsService(),
          MockMarketingAnalyticsService(),
        ),
      );
      urlOpener = MockUrlOpener();
      di.registerLazySingleton<UrlOpener>(() => urlOpener);
      overlayManager = MockOverlayManager();
      getAllCollectionsUseCase = MockGetAllCollectionsUseCase();
      needToShowOnboardingUseCase = MockNeedToShowOnboardingUseCase();
      markOnboardingTypeCompletedUseCase =
          MockMarkOnboardingTypeCompletedUseCase();
      listenCollectionsUseCase = MockListenCollectionsUseCase();
      hapticFeedbackMediumUseCase = MockHapticFeedbackMediumUseCase();
      dateTimeHandler = MockDateTimeHandler();
      actions = MockPersonalAreaNavActions();
      featureManager = MockFeatureManager();
      getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
      listenSubscriptionStatusUseCase = MockListenSubscriptionStatusUseCase();
      uniqueIdHandler = MockUniqueIdHandler();
      _mockManagerInitMethodCalls();
    },
  );

  PersonalAreaManager create({
    bool setMockOverlayManager = false,
  }) {
    final manager = PersonalAreaManager(
      getAllCollectionsUseCase,
      listenCollectionsUseCase,
      hapticFeedbackMediumUseCase,
      actions,
      featureManager,
      getSubscriptionStatusUseCase,
      listenSubscriptionStatusUseCase,
      uniqueIdHandler,
      needToShowOnboardingUseCase,
      markOnboardingTypeCompletedUseCase,
    );
    if (setMockOverlayManager) {
      manager.setOverlayManager(overlayManager);
    }
    return manager;
  }

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN manager is created and the free trial is NOT active THEN get collections and emit state populated with only collections',
    build: () => create(),
    verify: (manager) {
      expect(manager.state, equals(populatedStateOnlyCollections));
    },
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN manager is created and the free trial is active THEN emit state populated with trial banner and collections',
    build: () => create(),
    setUp: () {
      when(getSubscriptionStatusUseCase.singleOutput(any))
          .thenAnswer((_) async => subscriptionStatusFreeTrial);
      when(featureManager.isPaymentEnabled).thenReturn(true);
    },
    verify: (manager) {
      expect(manager.state, equals(populatedStateWithTrialBanner));
    },
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN onHomeNavPressed is called THEN redirected to action',
    build: () => create(),
    act: (manager) => manager.onHomeNavPressed(),
    verify: (manager) {
      verify(actions.onHomeNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN onActiveSearchNavPressed is called THEN redirected to action',
    build: () => create(),
    act: (manager) => manager.onActiveSearchNavPressed(),
    verify: (manager) {
      verify(actions.onActiveSearchNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN onSettingsNavPressed is called THEN redirected to action',
    build: () => create(),
    act: (manager) => manager.onSettingsNavPressed(),
    verify: (manager) {
      verify(actions.onSettingsNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'GIVEN true WHEN _needToShowOnboardingUseCase is called THEN overlay manager called',
    build: () => create(setMockOverlayManager: true),
    setUp: () {
      when(needToShowOnboardingUseCase
              .singleOutput(OnboardingType.collectionsManage))
          .thenAnswer((_) async => true);
    },
    act: (manager) => manager.checkIfNeedToShowOnboarding(),
    verify: (manager) {
      verifyInOrder([
        featureManager.isOnBoardingSheetsEnabled,
        needToShowOnboardingUseCase
            .singleOutput(OnboardingType.collectionsManage),
        overlayManager.show(any),
        overlayManager.onNewState(any)
      ]);
      verifyNoMoreInteractions(needToShowOnboardingUseCase);
      verifyNoMoreInteractions(manager.overlayManager);
    },
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'GIVEN false WHEN _needToShowOnboardingUseCase is called THEN overlay manager NOT called',
    build: () => create(setMockOverlayManager: true),
    setUp: () {
      when(needToShowOnboardingUseCase
              .singleOutput(OnboardingType.collectionsManage))
          .thenAnswer((_) async => false);
    },
    act: (manager) => manager.checkIfNeedToShowOnboarding(),
    verify: (manager) {
      verifyInOrder([
        featureManager.isOnBoardingSheetsEnabled,
        needToShowOnboardingUseCase
            .singleOutput(OnboardingType.collectionsManage),
      ]);
      verifyNoMoreInteractions(needToShowOnboardingUseCase);
      verifyZeroInteractions(manager.overlayManager);
    },
  );
}
