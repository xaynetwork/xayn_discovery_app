import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/restore_purchased_subsctiption_use_case.dart';

import '../../../presentation/test_utils/utils.dart';

void main() {
  late MockPaymentService paymentService;
  late RestorePurchasedSubscriptionUseCase useCase;

  setUp(() {
    paymentService = MockPaymentService();
    when(paymentService.isAvailable()).thenAnswer((_) => Future.value(true));
    when(paymentService.restorePurchases()).thenAnswer((_) async => {});

    useCase = RestorePurchasedSubscriptionUseCase(paymentService);
  });

  useCaseTest<RestorePurchasedSubscriptionUseCase, None, None>(
    'WHEN paymentService not available THEN throw storeNotAvailable error',
    setUp: () {
      when(paymentService.isAvailable()).thenAnswer((_) async => false);
    },
    build: () => useCase,
    input: {none},
    expect: [
      useCaseFailure(throwsA(PaymentFlowError.storeNotAvailable)),
    ],
    verify: (_) {
      verify(paymentService.isAvailable());
      verifyNoMoreInteractions(paymentService);
    },
  );

  useCaseTest<RestorePurchasedSubscriptionUseCase, None, None>(
    'WHEN paymentService is available THEN call restorePurchase and yield non',
    build: () => useCase,
    input: {none},
    expect: [useCaseSuccess(none)],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.restorePurchases(),
      ]);
      verifyNoMoreInteractions(paymentService);
    },
  );
}
