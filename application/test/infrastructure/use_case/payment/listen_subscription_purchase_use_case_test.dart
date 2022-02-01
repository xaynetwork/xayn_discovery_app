import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_purchase_use_case.dart';

import '../../../presentation/test_utils/utils.dart';
import 'payment_test_data.dart';

void main() {
  late MockPaymentService paymentService;
  late MockIAPErrorToPaymentFlowErrorMapper mapper;
  late ListenSubscriptionPurchaseUseCase useCase;

  setUp(() {
    paymentService = MockPaymentService();
    mapper = MockIAPErrorToPaymentFlowErrorMapper();

    useCase = ListenSubscriptionPurchaseUseCase(paymentService, mapper);
  });

  useCaseTest<ListenSubscriptionPurchaseUseCase, None,
      PurchasableProductStatus>(
    'GIVEN empty purchaseStream  THEN nothing yielded',
    build: () => useCase,
    setUp: () {
      when(paymentService.purchaseStream)
          .thenAnswer((realInvocation) => const Stream.empty());
    },
    input: {none},
    take: 1,
    verify: (_) {
      verify(paymentService.purchaseStream);
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  useCaseTest<ListenSubscriptionPurchaseUseCase, None,
      PurchasableProductStatus>(
    'GIVEN purchaseStream with items without subscription id THEN nothing yielded',
    build: () => useCase,
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer(
        (realInvocation) => Stream.value(
          [createPurchase(PurchaseStatus.pending, id: 'another id')],
        ),
      );
    },
    input: {none},
    take: 1,
    verify: (_) {
      verify(paymentService.purchaseStream);
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  useCaseTest<ListenSubscriptionPurchaseUseCase, None,
      PurchasableProductStatus>(
    'GIVEN purchaseStream with subscription pending status THEN yield PurchasableProductStatus.pending',
    build: () => useCase,
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer(
        (realInvocation) => Stream.value(
          [createPurchase(PurchaseStatus.pending)],
        ),
      );
    },
    input: {none},
    expect: [useCaseSuccess(PurchasableProductStatus.pending)],
    verify: (_) {
      verify(paymentService.purchaseStream);
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  useCaseTest<ListenSubscriptionPurchaseUseCase, None,
      PurchasableProductStatus>(
    'GIVEN purchaseStream with subscription purchased status THEN yield PurchasableProductStatus.purchased',
    build: () => useCase,
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer(
        (realInvocation) => Stream.value(
          [purchasedPurchaseDetails],
        ),
      );
    },
    input: {none},
    expect: [useCaseSuccess(PurchasableProductStatus.purchased)],
    verify: (_) {
      verifyInOrder([
        paymentService.purchaseStream,
        paymentService.completePurchase(purchasedPurchaseDetails)
      ]);
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  useCaseTest<ListenSubscriptionPurchaseUseCase, None,
      PurchasableProductStatus>(
    'GIVEN purchaseStream with subscription restored status THEN yield PurchasableProductStatus.restored',
    build: () => useCase,
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer(
        (realInvocation) => Stream.value(
          [restoredPurchaseDetails],
        ),
      );
    },
    input: {none},
    expect: [useCaseSuccess(PurchasableProductStatus.restored)],
    verify: (_) {
      verifyInOrder([
        paymentService.purchaseStream,
        paymentService.completePurchase(restoredPurchaseDetails)
      ]);
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  useCaseTest<ListenSubscriptionPurchaseUseCase, None,
      PurchasableProductStatus>(
    'GIVEN purchaseStream with subscription canceled status THEN yield PurchasableProductStatus.canceled',
    build: () => useCase,
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer(
        (realInvocation) => Stream.value(
          [createPurchase(PurchaseStatus.canceled)],
        ),
      );
    },
    input: {none},
    expect: [useCaseSuccess(PurchasableProductStatus.canceled)],
    verify: (_) {
      verify(paymentService.purchaseStream);
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  useCaseTest<ListenSubscriptionPurchaseUseCase, None,
      PurchasableProductStatus>(
    'GIVEN purchaseStream with subscription error status THEN yield PurchasableProductStatus.error',
    build: () => useCase,
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer(
        (realInvocation) => Stream.value(
          [createPurchase(PurchaseStatus.error)],
        ),
      );
      when(mapper.map(iapError)).thenReturn(PaymentFlowError.unknown);
    },
    input: {none},
    expect: [useCaseFailure(throwsA(PaymentFlowError.unknown))],
    verify: (_) {
      verify(paymentService.purchaseStream);
      verify(mapper.map(iapError));
      verifyNoMoreInteractions(paymentService);
      verifyNoMoreInteractions(mapper);
    },
  );
}
