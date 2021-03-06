import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_mock_data.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/purchase_subscription_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockPaymentService paymentService;
  late MockPurchasesErrorCodeToPaymentFlowErrorMapper mapper;
  late PurchaseSubscriptionUseCase useCase;
  setUp(() {
    paymentService = MockPaymentService();
    mapper = MockPurchasesErrorCodeToPaymentFlowErrorMapper();
    useCase = PurchaseSubscriptionUseCase(paymentService, mapper);
  });

  test(
    'GIVEN CustomerInfo that contains product id THEN yield PurchasableProductStatus.purchased',
    () async {
      // ARRANGE
      when(paymentService.purchaseProduct(PaymentMockData.productId))
          .thenAnswer(
        (_) async =>
            PaymentMockData.createCustomerInfo(withActiveSubscription: true),
      );

      // ACT
      final output = await useCase.call(PaymentMockData.productId);

      // ASSERT
      expect(
        output,
        equals([
          useCaseSuccess(PurchasableProductStatus.purchasePending),
          useCaseSuccess(PurchasableProductStatus.purchased),
        ]),
      );
      verify(paymentService.purchaseProduct(PaymentMockData.productId));
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  test(
    'GIVEN CustomerInfo that DOES NOT contains product id THEN throw PaymentFlowError.paymentFailed',
    () async {
      // ARRANGE
      when(paymentService.purchaseProduct(PaymentMockData.productId))
          .thenAnswer(
        (_) async =>
            PaymentMockData.createCustomerInfo(withActiveSubscription: false),
      );

      // ACT
      final output = await useCase.call(PaymentMockData.productId);

      // ASSERT
      expect(
        output,
        equals([
          useCaseSuccess(PurchasableProductStatus.purchasePending),
          useCaseFailure(throwsA(PaymentFlowError.paymentFailed)),
        ]),
      );
      verify(paymentService.purchaseProduct(PaymentMockData.productId));
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  test(
    'GIVEN PlatformException with canceled code WHEN purchaseProduct called THEN yield yield PurchasableProductStatus.canceled',
    () async {
      // ARRANGE
      when(paymentService.purchaseProduct(PaymentMockData.productId))
          .thenThrow(PlatformException(code: '1'));

      // ACT
      final output = await useCase.call(PaymentMockData.productId);

      // ASSERT
      expect(
        output,
        equals([
          useCaseSuccess(PurchasableProductStatus.purchasePending),
          useCaseSuccess(PurchasableProductStatus.canceled),
        ]),
      );
      verify(paymentService.purchaseProduct(PaymentMockData.productId));
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  PurchasesErrorCode.values
      .where((e) => e != PurchasesErrorCode.purchaseCancelledError)
      .forEach((error) {
    final errorCode = PurchasesErrorCode.values.indexOf(error);
    test(
      'GIVEN PlatformException with $error (code$errorCode) WHEN purchaseProduct called THEN use mapper and throw',
      () async {
        // ARRANGE
        when(paymentService.purchaseProduct(PaymentMockData.productId))
            .thenThrow(PlatformException(code: '$errorCode'));
        when(mapper.map(error)).thenReturn(PaymentFlowError.unknown);

        // ACT
        final output = await useCase.call(PaymentMockData.productId);

        // ASSERT
        expect(
          output,
          equals([
            useCaseSuccess(PurchasableProductStatus.purchasePending),
            useCaseFailure(throwsA(PaymentFlowError.unknown)),
          ]),
        );
        verifyInOrder([
          paymentService.purchaseProduct(PaymentMockData.productId),
          mapper.map(error),
        ]);
        verifyNoMoreInteractions(paymentService);
        verifyNoMoreInteractions(mapper);
      },
    );
  });
}
