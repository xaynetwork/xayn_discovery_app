import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:purchases_flutter/errors.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/aip_error_to_payment_flow_error_mapper.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockBugReportingService bugReportingService;
  late PurchasesErrorCodeToPaymentFlowErrorMapper mapper;
  final mapOfErrors = <PaymentFlowError, Set<PurchasesErrorCode>>{
    PaymentFlowError.canceled: {
      PurchasesErrorCode.purchaseCancelledError,
    },
    PaymentFlowError.itemAlreadyOwned: {
      PurchasesErrorCode.productAlreadyPurchasedError
    },
    PaymentFlowError.productNotFound: {
      PurchasesErrorCode.productNotAvailableForPurchaseError
    },
    PaymentFlowError.storeNotAvailable: {PurchasesErrorCode.storeProblemError},
    PaymentFlowError.paymentFailed: {
      PurchasesErrorCode.missingReceiptFileError,
      PurchasesErrorCode.insufficientPermissionsError,
      PurchasesErrorCode.purchaseInvalidError,
      PurchasesErrorCode.purchaseNotAllowedError,
      PurchasesErrorCode.paymentPendingError,
    },
    PaymentFlowError.unknown: {
      PurchasesErrorCode.unknownError,
      PurchasesErrorCode.invalidReceiptError,
      PurchasesErrorCode.invalidAppUserIdError,
      PurchasesErrorCode.invalidCredentialsError,
      PurchasesErrorCode.invalidAppleSubscriptionKeyError,
      PurchasesErrorCode.invalidSubscriberAttributesError,
      PurchasesErrorCode.unsupportedError,
      PurchasesErrorCode.configurationError,
      PurchasesErrorCode.unexpectedBackendResponseError,
      PurchasesErrorCode.operationAlreadyInProgressError,
      PurchasesErrorCode.unknownBackendError,
      PurchasesErrorCode.receiptAlreadyInUseError,
      PurchasesErrorCode.receiptInUseByOtherSubscriberError,
      PurchasesErrorCode.networkError,
      PurchasesErrorCode.logOutWithAnonymousUserError,
      PurchasesErrorCode.ineligibleError,
    },
    PaymentFlowError.noActiveSubscriptionFound: {},
  };
  setUp(() {
    bugReportingService = MockBugReportingService();
    mapper = PurchasesErrorCodeToPaymentFlowErrorMapper(bugReportingService);
  });

  test(
    'GIVEN mapOfErrors THEN verify keys and values sizes are correct',
    () async {
      // ARRANGE
      final keysSize = mapOfErrors.keys.toSet().length;
      final valuesSize =
          mapOfErrors.values.toSet().expand((e) => e).toSet().length;

      // ASSERT
      expect(keysSize, equals(PaymentFlowError.values.length));
      expect(valuesSize, equals(PurchasesErrorCode.values.length));
    },
  );

  for (final paymentError in mapOfErrors.keys) {
    test(
      'GIVEN set of PurchasesErrorCode THEN verify that every one of those returns correct $paymentError',
      () async {
        final errors = mapOfErrors[paymentError]!;
        final result = errors.map(mapper.map).toSet();
        if (paymentError == PaymentFlowError.noActiveSubscriptionFound) {
          expect(result.length, equals(0));
          return;
        }
        expect(result.length, equals(1));
        expect(result.first, equals(paymentError));
      },
    );
  }

  test(
    'GIVEN PurchasesErrorCode values THEN verify bugReport captured for all, except canceled',
    () async {
      PurchasesErrorCode.values.map(mapper.map).toList();

      PurchasesErrorCode.values
          .where((e) => e != PurchasesErrorCode.purchaseCancelledError)
          .forEach((element) {
        verify(bugReportingService.reportHandledCrash(element.toString(), any));
      });
      verifyNoMoreInteractions(bugReportingService);
    },
  );
}
