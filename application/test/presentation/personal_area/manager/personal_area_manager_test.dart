import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockPersonalAreaNavActions actions;
  late MockFeatureManager featureManager;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  final subscriptionStatus = SubscriptionStatus.initial();
  final readyState = PersonalAreaState(
    subscriptionStatus: subscriptionStatus,
    isPaymentEnabled: false,
  );

  setUp(() {
    actions = MockPersonalAreaNavActions();
    featureManager = MockFeatureManager();
    getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();

    when(getSubscriptionStatusUseCase.singleOutput(PurchasableIds.subscription))
        .thenAnswer((_) => Future.value(subscriptionStatus));
    when(featureManager.isPaymentEnabled).thenReturn(false);
  });

  PersonalAreaManager create() => PersonalAreaManager(
        actions,
        featureManager,
        getSubscriptionStatusUseCase,
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
    'WHEN onHomeFeedSettingsNavPressed is called THEN redirected to action',
    build: () => create(),
    act: (manager) => manager.onHomeFeedSettingsNavPressed(),
    verify: (manager) {
      verify(actions.onHomeFeedSettingsNavPressed());
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
