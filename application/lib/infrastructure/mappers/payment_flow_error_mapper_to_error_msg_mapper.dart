import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

@lazySingleton
class PaymentFlowErrorToErrorMessageMapper
    implements Mapper<PaymentFlowError, String> {
  @override
  String map(PaymentFlowError input) {
    switch (input) {
      case PaymentFlowError.unknown:
        return R.strings.paymentFlowError.unknown;
      case PaymentFlowError.storeNotAvailable:
        return R.strings.paymentFlowError.storeNotAvailable;
      case PaymentFlowError.productNotFound:
        return R.strings.paymentFlowError.productNotFound;
      case PaymentFlowError.itemAlreadyOwned:
        return R.strings.paymentFlowError.itemAlreadyOwned;
      case PaymentFlowError.paymentFailed:
        return R.strings.paymentFlowError.transactionFailed;
      case PaymentFlowError.checkSubscriptionActiveFailed:
        return R.strings.paymentFlowError.checkSubscriptionActiveFailed;
    }
  }
}
