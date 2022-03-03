import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';

import '../../../presentation/test_utils/utils.dart';
import 'payment_test_data.dart';

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
  });

  test(
    'GIVEN purchaseInfo with active subscription THEN yield false',
    () async {
      when(paymentService.getPurchaserInfo()).thenAnswer(
        (_) async => createPurchaserInfo(withActiveSubscription: true),
      );
      // ACT
      final subscriptionStatus = await useCase.singleOutput(subscriptionId);

      // ASSERT
      expect(subscriptionStatus.isSubscriptionActive, isTrue);
      expect(subscriptionStatus.isTrialActive, isTrue);
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
        (_) async => createPurchaserInfo(withActiveSubscription: false),
      );

      // ACT
      final subscriptionStatus = await useCase.singleOutput(subscriptionId);

      // ASSERT
      expect(subscriptionStatus.isSubscriptionActive, isFalse);
      expect(subscriptionStatus.isTrialActive, isFalse);
      expect(subscriptionStatus.willRenew, isFalse);
      expect(subscriptionStatus.expirationDate, isNull);
      expect(subscriptionStatus.trialEndDate, isNull);
      verify(paymentService.getPurchaserInfo());
      verifyNoMoreInteractions(paymentService);
    },
  );
}
