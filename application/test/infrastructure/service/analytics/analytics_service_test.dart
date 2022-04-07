import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/number_of_active_selected_countries_identity_param.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/number_of_total_sessions_identity_param.dart';

import '../../../presentation/test_utils/utils.dart';
import 'analytics_service_test_utils.dart';

void main() async {
  late MockAmplitude amplitude;
  late AmplitudeAnalyticsService analyticsService;
  final mockInAppEvent = FakeAnalyticsEvent();

  setUp(() {
    amplitude = MockAmplitude();
    analyticsService = AmplitudeAnalyticsService(
      amplitude: amplitude,
      userId: 'userId',
      initialized: true,
    );
  });

  group('Analytics Service', () {
    test('send', () {
      analyticsService.send(mockInAppEvent);
      verify(amplitude.logEvent(
        mockInAppEvent.type,
        eventProperties: mockInAppEvent.properties,
      )).called(1);
    });

    test('flush', () {
      analyticsService.flush();
      verify(amplitude.uploadEvents()).called(1);
    });
  });

  test(
    'GIVEN identityParam WHEN updateParam THEN amplitude set param as well',
    () async {
      const param = NumberOfActiveSelectedCountriesIdentityParam(2);

      expect(
        analyticsService.identify.payload.isEmpty,
        isTrue,
      );
      await analyticsService.updateIdentityParam(param);

      final map = HashMap.from(analyticsService.identify.payload.values.first);

      expect(
        map.containsKey(param.key),
        isTrue,
      );
      expect(
        map[param.key],
        equals(param.value),
      );
      verify(amplitude.identify(analyticsService.identify));
    },
  );

  test(
    'GIVEN a list of identityParams WHEN updateParam THEN amplitude set params as well',
    () async {
      final params = {
        const NumberOfActiveSelectedCountriesIdentityParam(2),
        const NumberOfTotalSessionIdentityParam(3),
      };

      expect(
        analyticsService.identify.payload.isEmpty,
        isTrue,
      );
      await analyticsService.updateIdentityParams(params);

      final map = HashMap.from(analyticsService.identify.payload.values.first);

      expect(
        map.containsKey(params.first.key),
        isTrue,
      );
      expect(
        map.containsKey(params.last.key),
        isTrue,
      );
      expect(
        map[params.first.key],
        equals(params.first.value),
      );
      expect(
        map[params.last.key],
        equals(params.last.value),
      );
      verify(amplitude.identify(analyticsService.identify));
    },
  );
}
