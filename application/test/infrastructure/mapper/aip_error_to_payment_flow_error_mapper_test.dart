import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/aip_error_to_payment_flow_error_mapper.dart';

void main() {
  late IAPErrorToPaymentFlowErrorMapper mapper;
  setUp(() {
    mapper = IAPErrorToPaymentFlowErrorMapper();
  });

  IAPError create(String msg) =>
      IAPError(source: 'play', code: 'code', message: msg);

  test(
    'GIVEN IAPError with message == "itemAlreadyOwned" THEN return itemAlreadyOwned',
    () async {
      expect(
        mapper.map(create('BillingResponse.itemAlreadyOwned')),
        equals(PaymentFlowError.itemAlreadyOwned),
      );
    },
  );
  test(
    'GIVEN IAPError with message == "error" THEN return itemAlreadyOwned',
    () async {
      expect(
        mapper.map(create('BillingResponse.error')),
        equals(PaymentFlowError.paymentFailed),
      );
    },
  );
}
