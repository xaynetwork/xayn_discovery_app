import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';

@lazySingleton
class PurchasesErrorCodeToPaymentFlowErrorMapper
    implements Mapper<PurchasesErrorCode, PaymentFlowError> {
  final BugReportingService _bugReportingService;

  PurchasesErrorCodeToPaymentFlowErrorMapper(
    this._bugReportingService,
  );

  @override
  PaymentFlowError map(PurchasesErrorCode input) {
    var reportIssue = true;
    try {
      switch (input) {
        case PurchasesErrorCode.productAlreadyPurchasedError:
          return PaymentFlowError.itemAlreadyOwned;

        case PurchasesErrorCode.purchaseCancelledError:
          reportIssue = false;
          return PaymentFlowError.canceled;

        case PurchasesErrorCode.productNotAvailableForPurchaseError:
          return PaymentFlowError.productNotFound;

        case PurchasesErrorCode.storeProblemError:
          return PaymentFlowError.storeNotAvailable;

        case PurchasesErrorCode.paymentPendingError:
        case PurchasesErrorCode.purchaseNotAllowedError:
        case PurchasesErrorCode.purchaseInvalidError:
        case PurchasesErrorCode.insufficientPermissionsError:
        case PurchasesErrorCode.missingReceiptFileError:
          return PaymentFlowError.paymentFailed;

        case PurchasesErrorCode.unknownError:
        case PurchasesErrorCode.invalidReceiptError:
        case PurchasesErrorCode.invalidAppUserIdError:
        case PurchasesErrorCode.invalidCredentialsError:
        case PurchasesErrorCode.invalidAppleSubscriptionKeyError:
        case PurchasesErrorCode.invalidSubscriberAttributesError:
        case PurchasesErrorCode.unsupportedError:
        case PurchasesErrorCode.configurationError:
        case PurchasesErrorCode.unexpectedBackendResponseError:
        case PurchasesErrorCode.operationAlreadyInProgressError:
        case PurchasesErrorCode.unknownBackendError:
        case PurchasesErrorCode.receiptAlreadyInUseError:
        case PurchasesErrorCode.receiptInUseByOtherSubscriberError:
        case PurchasesErrorCode.networkError:
        case PurchasesErrorCode.logOutWithAnonymousUserError:
        case PurchasesErrorCode.ineligibleError:
          return PaymentFlowError.unknown;
      }
    } finally {
      if (reportIssue) {
        _bugReportingService.reportHandledCrash(
          input.toString(),
          StackTrace.current,
        );
      }
    }
  }
}
