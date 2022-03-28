import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';

import '../../settings/manager/settings_manager_test.mocks.dart';
import '../../test_utils/utils.dart';

void main() {
  late MockPersonalAreaNavActions actions;
  late MockFeatureManager featureManager;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockListenSubscriptionStatusUseCase listenSubscriptionStatusUseCase;
  final subscriptionStatus = SubscriptionStatus.initial();
  final readyState = PersonalAreaState(
    subscriptionStatus: subscriptionStatus,
    isPaymentEnabled: false,
  );
  late UrlOpener urlOpener;

  setUp(() {
    di.allowReassignment = true;
    di.registerLazySingleton<SendAnalyticsUseCase>(
        () => SendAnalyticsUseCase(MockAnalyticsService()));
    urlOpener = MockUrlOpener();
    di.registerLazySingleton<UrlOpener>(() => urlOpener);
    actions = MockPersonalAreaNavActions();
    featureManager = MockFeatureManager();
    getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
    listenSubscriptionStatusUseCase = MockListenSubscriptionStatusUseCase();

    when(getSubscriptionStatusUseCase.singleOutput(PurchasableIds.subscription))
        .thenAnswer((_) async => subscriptionStatus);
    when(listenSubscriptionStatusUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(subscriptionStatus));
    when(listenSubscriptionStatusUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(featureManager.isPaymentEnabled).thenReturn(false);
  });

  PersonalAreaManager create() => PersonalAreaManager(
        actions,
        featureManager,
        getSubscriptionStatusUseCase,
        listenSubscriptionStatusUseCase,
      );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN manager is created THEN state is ready',
    build: () => create(),
    verify: (manager) {
      expect(manager.state, equals(readyState));
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
    'WHEN onCollectionsNavPressed is called THEN redirected to action',
    build: () => create(),
    act: (manager) => manager.onCollectionsNavPressed(),
    verify: (manager) {
      verify(actions.onCollectionsNavPressed());
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
}
