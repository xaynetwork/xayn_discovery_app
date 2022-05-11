import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_details_use_case.dart';

import '../../../test_utils/utils.dart';
import 'payment_test_data.dart';

void main() {
  late MockPaymentService paymentService;
  late MockPurchasableProductMapper mapper;
  late GetSubscriptionDetailsUseCase useCase;

  setUp(() {
    paymentService = MockPaymentService();
    mapper = MockPurchasableProductMapper();
    useCase = GetSubscriptionDetailsUseCase(paymentService, mapper);

    when(paymentService.getPackages()).thenAnswer(
      (_) async => [package],
    );
    when(mapper.map(package)).thenReturn(purchasableProduct);
  });

  useCaseTest<GetSubscriptionDetailsUseCase, None, PurchasableProduct>(
    'WHEN paymentService can not find product THEN throw productNotFound error',
    setUp: () {
      when(paymentService.getPackages()).thenAnswer(
        (_) async => [],
      );
    },
    build: () => useCase,
    input: {none},
    expect: [
      useCaseFailure(throwsA(PaymentFlowError.productNotFound)),
    ],
    verify: (_) {
      verify(paymentService.getPackages());
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  useCaseTest<GetSubscriptionDetailsUseCase, None, PurchasableProduct>(
    'WHEN paymentService found the product THEN map it and yield',
    build: () => useCase,
    input: {none},
    expect: [
      useCaseSuccess(purchasableProduct),
    ],
    verify: (_) {
      verifyInOrder([
        paymentService.getPackages(),
        mapper.map(package),
      ]);
      verifyNoMoreInteractions(mapper);
      verifyNoMoreInteractions(paymentService);
    },
  );
}
