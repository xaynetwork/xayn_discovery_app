import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/list_item_model.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/new_personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/new_personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';

import '../../test_utils/utils.dart';

void main() {
  late NewPersonalAreaNavActions actions;
  late MockFeatureManager featureManager;
  late MockGetAllCollectionsUseCase getAllCollectionsUseCase;
  late MockListenCollectionsUseCase listenCollectionsUseCase;
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
  );

  late UrlOpener urlOpener;
  final collection1 =
      Collection(id: UniqueId(), name: 'Collection1 name', index: 0);
  final collection2 =
      Collection(id: UniqueId(), name: 'Collection2 name', index: 1);

  final collectionsList = [
    ListItemModel.collection(
      id: collection1.id,
      collection: collection1,
    ),
    ListItemModel.collection(
      id: collection2.id,
      collection: collection2,
    )
  ];

  final populatedStateOnlyCollections = NewPersonalAreaState.populated(
    collectionsList,
    timeStamp,
  );

  final populatedStateWithTrialBanner = NewPersonalAreaState.populated(
    [
      ListItemModel.payment(
        id: paymentItemId,
        trialEndDate: subscriptionStatusFreeTrial.trialEndDate!,
      ),
      collectionsList[0],
      collectionsList[1],
    ],
    timeStamp,
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
    when(getSubscriptionStatusUseCase.singleOutput(PurchasableIds.subscription))
        .thenAnswer((_) async => subscriptionStatusInitial);
    when(listenSubscriptionStatusUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(subscriptionStatusInitial));
    when(listenSubscriptionStatusUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(featureManager.isPaymentEnabled).thenReturn(false);
  }

  setUp(
    () {
      di.allowReassignment = true;
      di.registerLazySingleton<SendAnalyticsUseCase>(
          () => SendAnalyticsUseCase(MockAnalyticsService()));
      urlOpener = MockUrlOpener();
      di.registerLazySingleton<UrlOpener>(() => urlOpener);
      getAllCollectionsUseCase = MockGetAllCollectionsUseCase();
      listenCollectionsUseCase = MockListenCollectionsUseCase();
      hapticFeedbackMediumUseCase = MockHapticFeedbackMediumUseCase();
      dateTimeHandler = MockDateTimeHandler();
      actions = MockNewPersonalAreaNavActions();
      featureManager = MockFeatureManager();
      getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
      listenSubscriptionStatusUseCase = MockListenSubscriptionStatusUseCase();
      uniqueIdHandler = MockUniqueIdHandler();
      _mockManagerInitMethodCalls();
    },
  );

  NewPersonalAreaManager create() => NewPersonalAreaManager(
        getAllCollectionsUseCase,
        listenCollectionsUseCase,
        hapticFeedbackMediumUseCase,
        actions,
        dateTimeHandler,
        featureManager,
        getSubscriptionStatusUseCase,
        listenSubscriptionStatusUseCase,
        uniqueIdHandler,
      );

  blocTest<NewPersonalAreaManager, NewPersonalAreaState>(
    'WHEN manager is created and the free trial is NOT active THEN get collections and emit state populated with only collections',
    build: () => create(),
    verify: (manager) {
      expect(manager.state, equals(populatedStateOnlyCollections));
    },
  );

  blocTest<NewPersonalAreaManager, NewPersonalAreaState>(
    'WHEN manager is created and the free trial is active THEN emit state populated with trial banner and collections',
    build: () => create(),
    setUp: () {
      when(getSubscriptionStatusUseCase
              .singleOutput(PurchasableIds.subscription))
          .thenAnswer((_) async => subscriptionStatusFreeTrial);
      when(featureManager.isPaymentEnabled).thenReturn(true);
    },
    verify: (manager) {
      expect(manager.state, equals(populatedStateWithTrialBanner));
    },
  );

  blocTest<NewPersonalAreaManager, NewPersonalAreaState>(
    'WHEN onHomeNavPressed is called THEN redirected to action',
    build: () => create(),
    act: (manager) => manager.onHomeNavPressed(),
    verify: (manager) {
      verify(actions.onHomeNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<NewPersonalAreaManager, NewPersonalAreaState>(
    'WHEN onActiveSearchNavPressed is called THEN redirected to action',
    build: () => create(),
    act: (manager) => manager.onActiveSearchNavPressed(),
    verify: (manager) {
      verify(actions.onActiveSearchNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<NewPersonalAreaManager, NewPersonalAreaState>(
    'WHEN onSettingsNavPressed is called THEN redirected to action',
    build: () => create(),
    act: (manager) => manager.onSettingsNavPressed(),
    verify: (manager) {
      verify(actions.onSettingsNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );
}
