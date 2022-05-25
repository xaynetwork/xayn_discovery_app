import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_mock_data.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockPaymentService paymentService;
  late MockAppStatusRepository repository;
  late GetSubscriptionStatusUseCase useCase;
  setUp(() {
    paymentService = MockPaymentService();
    repository = MockAppStatusRepository();
    useCase = GetSubscriptionStatusUseCase(
      paymentService,
      repository,
    );
    when(repository.appStatus).thenAnswer((_) => AppStatus.initial());
  });

  test(
    'GIVEN purchaseInfo with active subscription THEN yield false',
    () async {
      when(paymentService.getPurchaserInfo()).thenAnswer(
        (_) async =>
            PaymentMockData.createPurchaserInfo(withActiveSubscription: true),
      );
      // ACT
      final subscriptionStatus = await useCase.singleOutput(none);

      // ASSERT
      expect(subscriptionStatus.isSubscriptionActive, isTrue);
      expect(subscriptionStatus.isFreeTrialActive, isFalse);
      expect(subscriptionStatus.willRenew, isTrue);
      expect(subscriptionStatus.expirationDate, isNotNull);
      expect(subscriptionStatus.trialEndDate, isNotNull);
      verify(paymentService.getPurchaserInfo());
      verifyNoMoreInteractions(paymentService);
    },
  );

  test(
    'GIVEN purchaseInfo without active subscription THEN yield false',
    () async {
      // ARRANGE
      when(paymentService.getPurchaserInfo()).thenAnswer(
        (_) async =>
            PaymentMockData.createPurchaserInfo(withActiveSubscription: false),
      );

      // ACT
      final subscriptionStatus = await useCase.singleOutput(none);

      // ASSERT
      expect(subscriptionStatus.isSubscriptionActive, isFalse);
      expect(subscriptionStatus.isFreeTrialActive, isTrue);
      expect(subscriptionStatus.willRenew, isFalse);
      expect(subscriptionStatus.expirationDate, isNull);
      expect(subscriptionStatus.trialEndDate, isNotNull);
      verify(paymentService.getPurchaserInfo());
      verifyNoMoreInteractions(paymentService);
    },
  );

  test(
    'GIVEN purchaseInfo without active subscription and is beta user THEN yield true',
    () async {
      // ARRANGE
      when(paymentService.getPurchaserInfo()).thenAnswer(
        (_) async =>
            PaymentMockData.createPurchaserInfo(withActiveSubscription: false),
      );

      when(repository.appStatus)
          .thenAnswer((_) => AppStatus.initial().copyWith(isBetaUser: true));

      // ACT
      final subscriptionStatus = await useCase.singleOutput(none);

      // ASSERT
      expect(subscriptionStatus.isSubscriptionActive, isTrue);
      expect(subscriptionStatus.isFreeTrialActive, isFalse);
      expect(subscriptionStatus.willRenew, isFalse);
      expect(subscriptionStatus.expirationDate, isNull);
      expect(subscriptionStatus.trialEndDate, isNotNull);
      verify(paymentService.getPurchaserInfo());
      verifyNoMoreInteractions(paymentService);
    },
  );
}
