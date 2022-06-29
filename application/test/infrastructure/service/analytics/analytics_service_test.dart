import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/number_of_active_selected_countries_identity_param.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/number_of_total_sessions_identity_param.dart';

import '../../../test_utils/utils.dart';
import 'analytics_service_test_utils.dart';

void main() async {
  late MockMixpanel mixpanel;
  late MockPeople profile;
  late MixpanelAnalyticsService analyticsService;
  final mockInAppEvent = FakeAnalyticsEvent();

  setUp(() {
    mixpanel = MockMixpanel();
    profile = MockPeople();

    when(mixpanel.getPeople()).thenReturn(profile);

    analyticsService = MixpanelAnalyticsService.test(
      mixpanel: mixpanel,
      userId: 'userId',
    );
  });

  group('Analytics Service', () {
    test('send', () {
      analyticsService.send(mockInAppEvent);
      verify(mixpanel.track(
        mockInAppEvent.type,
        properties: mockInAppEvent.properties,
      )).called(1);
    });

    test('flush', () {
      analyticsService.flush();
      verify(mixpanel.flush()).called(1);
    });
  });

  test('GIVEN identityParam WHEN updateParam THEN set param as well', () {
    const param = NumberOfActiveSelectedCountriesIdentityParam(2);
    analyticsService.updateIdentityParam(param);
    verify(profile.set(param.key, param.value)).called(1);
  });

  test(
    'GIVEN a list of identityParams WHEN updateParam THEN set params as well',
    () async {
      final params = {
        const NumberOfActiveSelectedCountriesIdentityParam(2),
        const NumberOfTotalSessionIdentityParam(3),
      };

      analyticsService.updateIdentityParams(params);

      verifyInOrder([
        profile.set(params.first.key, params.first.value),
        profile.set(params.last.key, params.last.value)
      ]);
    },
  );
}
