import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/check_subscription_active_use_case.dart';

import '../../../presentation/test_utils/utils.dart';
import 'payment_test_data.dart';

void main() {
  late MockPaymentService paymentService;
  late CheckSubscriptionActiveUseCase useCase;
  setUp(() {
    paymentService = MockPaymentService();
    useCase = CheckSubscriptionActiveUseCase(paymentService);
  });

  test(
    'GIVEN purchaseInfo with active subscription THEN yield false',
    () async {
      when(paymentService.getPurchaserInfo()).thenAnswer(
        (_) async => createPurchaserInfo(withActiveSubscription: true),
      );
      // ACT
      final isActive = await useCase.singleOutput(subscriptionId);

      // ASSERT
      expect(isActive, isTrue);
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
      final isActive = await useCase.singleOutput(subscriptionId);

      // ASSERT
      expect(isActive, isFalse);
      verify(paymentService.getPurchaserInfo());
      verifyNoMoreInteractions(paymentService);
    },
  );
}
