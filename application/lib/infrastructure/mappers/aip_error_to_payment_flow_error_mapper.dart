import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

const _itemAlreadyOwned = 'BillingResponse.itemAlreadyOwned';
const _paymentDeclined = 'BillingResponse.error';

@lazySingleton
class IAPErrorToPaymentFlowErrorMapper
    implements Mapper<IAPError, PaymentFlowError> {
  @override
  PaymentFlowError map(IAPError input) {
    switch (input.message) {
      case _itemAlreadyOwned:
        return PaymentFlowError.itemAlreadyOwned;
      case _paymentDeclined:
        return PaymentFlowError.paymentFailed;
      default:
        return PaymentFlowError.unknown;
    }
  }
}
