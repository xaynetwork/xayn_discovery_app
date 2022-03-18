import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/payment_flow_error_mapper_to_error_msg_mapper.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

void main() {
  final mapper = PaymentFlowErrorToErrorMessageMapper();

  final expectedResults = <String>[
    // The first one for PaymentFlowError.canceled
    R.strings.paymentFlowError.unknown,
    R.strings.paymentFlowError.unknown,
    R.strings.paymentFlowError.storeNotAvailable,
    R.strings.paymentFlowError.productNotFound,
    R.strings.paymentFlowError.itemAlreadyOwned,
    R.strings.paymentFlowError.transactionFailed,
    R.strings.paymentFlowError.noActiveSubscriptionFound,
  ];

  test(
    'GIVEN paymentErrorFlow WHEN map object THEN receive correct errorMsg',
    () {
      final results = PaymentFlowError.values.map(mapper.map).toList();
      expect(results, equals(expectedResults));
    },
  );
}
