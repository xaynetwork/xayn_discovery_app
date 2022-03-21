import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/number_of_active_selected_countries_identity_param.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_identity_param_use_case.dart';

import '../../../presentation/test_utils/utils.dart';

void main() {
  late SetIdentityParamUseCase useCase;
  late MockAnalyticsService analyticsService;

  setUp(() {
    analyticsService = MockAnalyticsService();
    useCase = SetIdentityParamUseCase(analyticsService);
  });

  test(
    'GIVEN useCase THEN verify call are correct',
    () async {
      const param = NumberOfActiveSelectedCountriesIdentityParam(3);

      final result = await useCase.singleOutput(param);

      expect(result, isA<None>());

      verify(analyticsService.updateIdentityParam(param));
      verifyNoMoreInteractions(analyticsService);
    },
  );
}
