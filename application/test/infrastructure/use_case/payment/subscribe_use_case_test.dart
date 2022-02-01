import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/subscribe_use_case.dart';

import '../../../presentation/test_utils/utils.dart';
import 'payment_test_data.dart';

void main() {
  late MockPaymentService paymentService;
  late SubscribeUseCase useCase;
  setUp(() {
    paymentService = MockPaymentService();
    useCase = SubscribeUseCase(paymentService);

    when(paymentService.isAvailable()).thenAnswer((_) => Future.value(true));
    when(paymentService.queryProductDetails({subscriptionId})).thenAnswer(
      (_) async => ProductDetailsResponse(
        productDetails: [productDetails],
        notFoundIDs: [],
      ),
    );
  });

  useCaseTest<SubscribeUseCase, None, None>(
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
      });

  useCaseTest<SubscribeUseCase, None, None>(
    'WHEN paymentService can not find product THEN throw productNotFound error',
    setUp: () {
      when(paymentService.queryProductDetails({subscriptionId})).thenAnswer(
        (_) async => ProductDetailsResponse(
          notFoundIDs: [subscriptionId],
          productDetails: [],
        ),
      );
    },
    build: () => useCase,
    input: {none},
    expect: [
      useCaseFailure(throwsA(PaymentFlowError.productNotFound)),
    ],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.queryProductDetails({subscriptionId}),
      ]);
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );
}
