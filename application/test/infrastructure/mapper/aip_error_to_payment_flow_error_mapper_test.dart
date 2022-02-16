import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/aip_error_to_payment_flow_error_mapper.dart';

import '../../presentation/test_utils/utils.dart';

void main() {
  late MockBugReportingService bugReportingService;
  late IAPErrorToPaymentFlowErrorMapper mapper;
  setUp(() {
    bugReportingService = MockBugReportingService();
    mapper = IAPErrorToPaymentFlowErrorMapper(bugReportingService);
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
      verifyZeroInteractions(bugReportingService);
    },
  );
  test(
    'GIVEN IAPError with message == "error" THEN return paymentFailed',
    () async {
      expect(
        mapper.map(create('BillingResponse.error')),
        equals(PaymentFlowError.paymentFailed),
      );
      verifyZeroInteractions(bugReportingService);
    },
  );
  test(
    'GIVEN IAPError with unknown message THEN return unknown and track error to bugReportingService',
    () async {
      final iapError = create('unknown');
      expect(
        mapper.map(iapError),
        equals(PaymentFlowError.unknown),
      );
      verify(bugReportingService.reportHandledCrash(iapError.toString(), any));
      verifyNoMoreInteractions(bugReportingService);
    },
  );
}
