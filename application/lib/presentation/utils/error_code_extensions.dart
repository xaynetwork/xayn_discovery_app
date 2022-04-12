import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';

const _paymentPrefix = '100';

extension PaymentFlowErrorExtension on PaymentFlowError {
  String get errorCode {
    switch (this) {
      case PaymentFlowError.canceled:
        return _paymentPrefix + '0';
      case PaymentFlowError.unknown:
        return _paymentPrefix + '1';
      case PaymentFlowError.storeNotAvailable:
        return _paymentPrefix + '2';
      case PaymentFlowError.productNotFound:
        return _paymentPrefix + '3';
      case PaymentFlowError.itemAlreadyOwned:
        return _paymentPrefix + '4';
      case PaymentFlowError.paymentFailed:
        return _paymentPrefix + '5';
      case PaymentFlowError.noActiveSubscriptionFound:
        return _paymentPrefix + '6';
    }
  }
}
