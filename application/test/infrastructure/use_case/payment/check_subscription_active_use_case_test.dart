import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/check_subscription_active_use_case.dart';

import '../../../presentation/test_utils/utils.dart';
import 'payment_test_data.dart';

void main() {
  late MockPaymentService paymentService;
  late CheckSubscriptionActiveUseCase useCase;
  const productId = 'productId';

  setUp(() {
    paymentService = MockPaymentService();
    when(paymentService.isAvailable()).thenAnswer((_) => Future.value(true));
    when(paymentService.restorePurchases()).thenAnswer((_) async => {});

    useCase = CheckSubscriptionActiveUseCase(paymentService);
  });

  useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
    'WHEN paymentService not available THEN throw storeNotAvailable error',
    setUp: () {
      when(paymentService.isAvailable()).thenAnswer((_) async => false);
    },
    build: () => useCase,
    input: {productId},
    expect: [
      useCaseFailure(throwsA(PaymentFlowError.storeNotAvailable)),
    ],
    verify: (_) {
      verify(paymentService.isAvailable());
      verifyNoMoreInteractions(paymentService);
    },
  );

  useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
    'GIVEN purchaseStream with empty list WHEN paymentService is available THEN call restorePurchase and yield false',
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([]));
    },
    build: () => useCase,
    input: {productId},
    expect: [useCaseSuccess(false)],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.restorePurchases(),
        paymentService.purchaseStream,
      ]);
      verifyNoMoreInteractions(paymentService);
    },
  );

  useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
    'GIVEN purchaseStream without desired productId WHEN paymentService is available THEN call restorePurchase and yield false',
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([
            createPurchase(PurchaseStatus.pending, id: 'another'),
          ]));
    },
    build: () => useCase,
    input: {productId},
    expect: [useCaseSuccess(false)],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.restorePurchases(),
        paymentService.purchaseStream,
      ]);
      verifyNoMoreInteractions(paymentService);
    },
  );

  group(
      'GIVEN purchaseStream with desired productId but with non restored status',
      () {
    PurchaseStatus.values
        .where((element) => element != PurchaseStatus.restored)
        .forEach(
      (status) {
        useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
          'GIVEN status $status WHEN paymentService is available THEN call restorePurchase and yield false',
          setUp: () {
            when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([
                  createPurchase(PurchaseStatus.pending, id: productId),
                ]));
          },
          build: () => useCase,
          input: {productId},
          expect: [useCaseSuccess(false)],
          verify: (_) {
            verifyInOrder([
              paymentService.isAvailable(),
              paymentService.restorePurchases(),
              paymentService.purchaseStream,
            ]);
            verifyNoMoreInteractions(paymentService);
          },
        );
      },
    );
  });

  useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
    'GIVEN ${PurchaseStatus.restored} WHEN paymentService is available THEN call restorePurchase and yield true',
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([
            createPurchase(PurchaseStatus.restored, id: productId),
          ]));
    },
    build: () => useCase,
    input: {productId},
    expect: [useCaseSuccess(true)],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.restorePurchases(),
        paymentService.purchaseStream,
      ]);
      verifyNoMoreInteractions(paymentService);
    },
  );
}
