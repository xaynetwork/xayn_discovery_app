import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/presentation/utils/map_utils.dart';
import 'analytics_service_test_utils.dart';
import 'analytics_service_test.mocks.dart';

@GenerateMocks([Amplitude])
void main() async {
  late MockAmplitude amplitude;
  late AnalyticsService analyticsService;
  final mockInAppEvent = FakeAnalyticsEvent();

  setUp(() {
    amplitude = MockAmplitude();
    analyticsService = AmplitudeAnalyticsService(
      amplitude: amplitude,
      initialized: true,
    );
  });

  group('Analytics Service', () {
    test('send', () {
      analyticsService.send(mockInAppEvent);
      verify(amplitude.logEvent(
        mockInAppEvent.type,
        eventProperties: mockInAppEvent.properties.toSerializableMap(),
      )).called(1);
    });

    test('flush', () {
      analyticsService.flush();
      verify(amplitude.uploadEvents()).called(1);
    });
  });
}
