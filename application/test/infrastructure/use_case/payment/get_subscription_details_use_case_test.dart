import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_details_use_case.dart';

import '../../../presentation/test_utils/utils.dart';
import 'payment_test_data.dart';

void main() {
  late MockPaymentService paymentService;
  late MockPurchasableProductMapper mapper;
  late GetSubscriptionDetailsUseCase useCase;

  setUp(() {
    paymentService = MockPaymentService();
    mapper = MockPurchasableProductMapper();
    useCase = GetSubscriptionDetailsUseCase(paymentService, mapper);

    when(paymentService.isAvailable()).thenAnswer((_) => Future.value(true));
    when(paymentService.queryProductDetails({subscriptionId})).thenAnswer(
      (_) async => ProductDetailsResponse(
        notFoundIDs: [],
        productDetails: [productDetails],
      ),
    );
    when(mapper.map(productDetails)).thenReturn(purchasableProduct);
  });

  useCaseTest<GetSubscriptionDetailsUseCase, None, PurchasableProduct>(
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
        verifyZeroInteractions(mapper);
        verify(paymentService.isAvailable());
        verifyNoMoreInteractions(paymentService);
      });

  useCaseTest<GetSubscriptionDetailsUseCase, None, PurchasableProduct>(
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

  useCaseTest<GetSubscriptionDetailsUseCase, None, PurchasableProduct>(
    'WHEN paymentService found the product THEN map it and yield',
    build: () => useCase,
    input: {none},
    expect: [
      useCaseSuccess(purchasableProduct),
    ],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.queryProductDetails({subscriptionId}),
        mapper.map(productDetails),
      ]);
      verifyNoMoreInteractions(mapper);
      verifyNoMoreInteractions(paymentService);
    },
  );
}
