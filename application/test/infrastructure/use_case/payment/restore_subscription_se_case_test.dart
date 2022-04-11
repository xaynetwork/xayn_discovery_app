import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/restore_subscription_use_case.dart';

import '../../../test_utils/utils.dart';
import 'payment_test_data.dart';

void main() {
  late MockPaymentService paymentService;
  late MockPurchasesErrorCodeToPaymentFlowErrorMapper mapper;
  late RestoreSubscriptionUseCase useCase;
  setUp(() {
    paymentService = MockPaymentService();
    mapper = MockPurchasesErrorCodeToPaymentFlowErrorMapper();
    useCase = RestoreSubscriptionUseCase(paymentService, mapper);
  });

  test(
    'GIVEN PurchaserInfo with active subscription THEN yield PurchasableProductStatus.restored',
    () async {
      // ARRANGE
      when(paymentService.restore()).thenAnswer(
        (_) async => createPurchaserInfo(withActiveSubscription: true),
      );

      // ACT
      final output = await useCase.call(none);

      // ASSERT
      expect(
        output,
        equals([
          useCaseSuccess(PurchasableProductStatus.restorePending),
          useCaseSuccess(PurchasableProductStatus.restored),
        ]),
      );
      verify(paymentService.restore());
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  test(
    'GIVEN PurchaserInfo without active subscription THEN throw PaymentFlowError.noActiveSubscriptionFound',
    () async {
      // ARRANGE
      when(paymentService.restore()).thenAnswer(
        (_) async => createPurchaserInfo(withActiveSubscription: false),
      );

      // ACT
      final output = await useCase.call(none);

      // ASSERT
      expect(
        output,
        equals([
          useCaseSuccess(PurchasableProductStatus.restorePending),
          useCaseFailure(throwsA(PaymentFlowError.noActiveSubscriptionFound)),
        ]),
      );
      verify(paymentService.restore());
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(mapper);
    },
  );

  PurchasesErrorCode.values
      .where((e) => e != PurchasesErrorCode.purchaseCancelledError)
      .forEach((error) {
    final errorCode = PurchasesErrorCode.values.indexOf(error);
    test(
      'GIVEN PlatformException with $error (code$errorCode) WHEN restore called THEN use mapper and throw',
      () async {
        // ARRANGE
        when(paymentService.restore())
            .thenThrow(PlatformException(code: '$errorCode'));
        when(mapper.map(error)).thenReturn(PaymentFlowError.unknown);

        // ACT
        final output = await useCase.call(none);

        // ASSERT
        expect(
          output,
          equals([
            useCaseSuccess(PurchasableProductStatus.restorePending),
            useCaseFailure(throwsA(PaymentFlowError.unknown)),
          ]),
        );
        verifyInOrder([
          paymentService.restore(),
          mapper.map(error),
        ]);
        verifyNoMoreInteractions(paymentService);
        verifyNoMoreInteractions(mapper);
      },
    );
  });
}
