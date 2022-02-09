import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';

const _itemAlreadyOwned = 'BillingResponse.itemAlreadyOwned';
const _paymentDeclined = 'BillingResponse.error';

@lazySingleton
class IAPErrorToPaymentFlowErrorMapper
    implements Mapper<IAPError, PaymentFlowError> {
  final BugReportingService _bugReportingService;

  IAPErrorToPaymentFlowErrorMapper(
    this._bugReportingService,
  );

  @override
  PaymentFlowError map(IAPError input) {
    switch (input.message) {
      case _itemAlreadyOwned:
        return PaymentFlowError.itemAlreadyOwned;
      case _paymentDeclined:
        return PaymentFlowError.paymentFailed;
      default:
        _bugReportingService.reportHandledCrash(
          input.toString(),
          StackTrace.current,
        );
        return PaymentFlowError.unknown;
    }
  }
}
