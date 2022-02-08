import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/purchase_subscription_use_case.dart';

import '../../../presentation/test_utils/utils.dart';
import 'payment_test_data.dart';

void main() {
  late MockPaymentService paymentService;
  late MockIAPErrorToPaymentFlowErrorMapper mapper;
  late PurchaseSubscriptionUseCase useCase;
  setUp(() {
    paymentService = MockPaymentService();
    mapper = MockIAPErrorToPaymentFlowErrorMapper();
    useCase = PurchaseSubscriptionUseCase(paymentService, mapper);

    when(paymentService.isAvailable()).thenAnswer((_) => Future.value(true));
    when(paymentService.queryProductDetails({subscriptionId})).thenAnswer(
      (_) async => ProductDetailsResponse(
        productDetails: [productDetails],
        notFoundIDs: [],
      ),
    );
    when(paymentService.buyNonConsumable(
      purchaseParam: anyNamed('purchaseParam'),
    )).thenAnswer((_) => Future.value(true));
  });

  useCaseTest<PurchaseSubscriptionUseCase, PurchasableProductId,
          PurchasableProductStatus>(
      'WHEN paymentService not available THEN throw storeNotAvailable error',
      setUp: () {
        when(paymentService.isAvailable()).thenAnswer((_) async => false);
      },
      build: () => useCase,
      input: {subscriptionId},
      expect: [
        useCaseFailure(throwsA(PaymentFlowError.storeNotAvailable)),
      ],
      verify: (_) {
        verify(paymentService.isAvailable());
        verifyNoMoreInteractions(paymentService);
      });

  useCaseTest<PurchaseSubscriptionUseCase, PurchasableProductId,
      PurchasableProductStatus>(
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
    input: {subscriptionId},
    expect: [
      useCaseFailure(throwsA(PaymentFlowError.productNotFound)),
    ],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.queryProductDetails({subscriptionId}),
      ]);
      verifyNoMoreInteractions(paymentService);
    },
  );

  group('Check stream response', () {
    useCaseTest<PurchaseSubscriptionUseCase, PurchasableProductId,
        PurchasableProductStatus>(
      'GIVEN purchaseStream with empty list THEN yields nothing',
      build: () => useCase,
      setUp: () {
        when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([]));
      },
      input: {subscriptionId},
      take: 1,
      verify: (_) {
        verifyInOrder([
          paymentService.isAvailable(),
          paymentService.queryProductDetails({subscriptionId}),
          paymentService.buyNonConsumable(
              purchaseParam: anyNamed('purchaseParam')),
          paymentService.purchaseStream,
        ]);
        verifyNoMoreInteractions(paymentService);
      },
    );
    useCaseTest<PurchaseSubscriptionUseCase, PurchasableProductId,
        PurchasableProductStatus>(
      'GIVEN purchaseStream with wrong id THEN yields nothing',
      build: () => useCase,
      setUp: () {
        when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([
              createPurchase(PurchaseStatus.pending, id: 'wrong id'),
            ]));
      },
      input: {subscriptionId},
      take: 1,
      verify: (_) {
        verifyInOrder([
          paymentService.isAvailable(),
          paymentService.queryProductDetails({subscriptionId}),
          paymentService.buyNonConsumable(
              purchaseParam: anyNamed('purchaseParam')),
          paymentService.purchaseStream,
        ]);
        verifyNoMoreInteractions(paymentService);
      },
    );

    useCaseTest<PurchaseSubscriptionUseCase, PurchasableProductId,
        PurchasableProductStatus>(
      'GIVEN PurchaseStatus pending THEN yields list of corresponding PurchasableProductStatus.pending',
      build: () => useCase,
      setUp: () {
        when(paymentService.purchaseStream).thenAnswer((_) => Stream.value(
              [createPurchase(PurchaseStatus.pending)],
            ));
      },
      input: {subscriptionId},
      expect: [
        useCaseSuccess(PurchasableProductStatus.pending),
      ],
      verify: (_) {
        verifyInOrder([
          paymentService.isAvailable(),
          paymentService.queryProductDetails({subscriptionId}),
          paymentService.buyNonConsumable(
              purchaseParam: anyNamed('purchaseParam')),
          paymentService.purchaseStream,
        ]);
        verifyNoMoreInteractions(paymentService);
      },
    );
    useCaseTest<PurchaseSubscriptionUseCase, PurchasableProductId,
        PurchasableProductStatus>(
      'GIVEN PurchaseStatus canceled THEN yields list of corresponding PurchasableProductStatus.canceled',
      build: () => useCase,
      setUp: () {
        when(paymentService.purchaseStream).thenAnswer((_) => Stream.value(
              [createPurchase(PurchaseStatus.canceled)],
            ));
      },
      input: {subscriptionId},
      expect: [
        useCaseSuccess(PurchasableProductStatus.canceled),
      ],
      verify: (_) {
        verifyInOrder([
          paymentService.isAvailable(),
          paymentService.queryProductDetails({subscriptionId}),
          paymentService.buyNonConsumable(
              purchaseParam: anyNamed('purchaseParam')),
          paymentService.purchaseStream,
        ]);
        verifyNoMoreInteractions(paymentService);
      },
    );
    useCaseTest<PurchaseSubscriptionUseCase, PurchasableProductId,
        PurchasableProductStatus>(
      'GIVEN PurchaseStatus purchased THEN yields list of corresponding PurchasableProductStatus.purchased',
      build: () => useCase,
      setUp: () {
        when(paymentService.purchaseStream).thenAnswer((_) => Stream.value(
              [purchasedPurchaseDetails],
            ));
      },
      input: {subscriptionId},
      expect: [
        useCaseSuccess(PurchasableProductStatus.purchased),
      ],
      verify: (_) {
        verifyInOrder([
          paymentService.isAvailable(),
          paymentService.queryProductDetails({subscriptionId}),
          paymentService.buyNonConsumable(
              purchaseParam: anyNamed('purchaseParam')),
          paymentService.purchaseStream,
          paymentService.completePurchase(purchasedPurchaseDetails),
        ]);
        verifyNoMoreInteractions(paymentService);
      },
    );
    useCaseTest<PurchaseSubscriptionUseCase, PurchasableProductId,
        PurchasableProductStatus>(
      'GIVEN PurchaseStatus restored THEN yields list of corresponding PurchasableProductStatus.restored',
      build: () => useCase,
      setUp: () {
        when(paymentService.purchaseStream).thenAnswer((_) => Stream.value(
              [restoredPurchaseDetails],
            ));
      },
      input: {subscriptionId},
      expect: [
        useCaseSuccess(PurchasableProductStatus.restored),
      ],
      verify: (_) {
        verifyInOrder([
          paymentService.isAvailable(),
          paymentService.queryProductDetails({subscriptionId}),
          paymentService.buyNonConsumable(
              purchaseParam: anyNamed('purchaseParam')),
          paymentService.purchaseStream,
          paymentService.completePurchase(restoredPurchaseDetails),
        ]);
        verifyNoMoreInteractions(paymentService);
      },
    );
  });
}
