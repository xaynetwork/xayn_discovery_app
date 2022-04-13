import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/request_code_redemption_sheet_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockPaymentService paymentService;
  late RequestCodeRedemptionSheetUseCase useCase;

  setUp(() {
    paymentService = MockPaymentService();
    useCase = RequestCodeRedemptionSheetUseCase.test(paymentService, true);
    when(paymentService.presentCodeRedemptionSheet())
        .thenAnswer((_) async => () {});
  });

  test(
    'GIVEN ios platform THEN yield none and call payment service',
    () async {
      final result = await useCase.call(none);

      expect(result, [useCaseSuccess(none)]);
      verify(paymentService.presentCodeRedemptionSheet());
      verifyNoMoreInteractions(paymentService);
    },
  );

  test(
    'GIVEN non ios platform THEN throw UnsupportedError',
    () async {
      useCase = RequestCodeRedemptionSheetUseCase.test(paymentService, false);

      final result = await useCase.call(none);

      expect(result, [useCaseFailure(throwsA(isA<UnsupportedError>()))]);
    },
  );
}
