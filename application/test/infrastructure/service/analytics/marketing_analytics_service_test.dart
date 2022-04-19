import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_analytics_service.dart';

import '../../../test_utils/utils.dart';
import 'analytics_service_test_utils.dart';

void main() async {
  late MockAppsflyerSdk appsFlyer;
  late MockDeepLinkManager deepLinkManager;
  late MarketingAnalyticsService marketingAnalyticsService;

  const mockUID = '123';
  const mockLanguage = 'en';
  final mockInAppEvent = FakeAnalyticsEvent();

  setUp(() {
    appsFlyer = MockAppsflyerSdk();
    deepLinkManager = MockDeepLinkManager();
    marketingAnalyticsService = AppsFlyerMarketingAnalyticsService(
      appsFlyer,
      deepLinkManager,
    );
  });

  group('Marketing Analytics Service', () {
    test('getUID', () {
      when(appsFlyer.getAppsFlyerUID()).thenAnswer(
        (_) async => mockUID,
      );

      final actual = marketingAnalyticsService.getUID();
      expect(actual, completion(equals(mockUID)));
    });

    test('send', () {
      when(appsFlyer.logEvent(any, any)).thenAnswer(
        (_) async => true,
      );

      marketingAnalyticsService.send(mockInAppEvent);
      verify(appsFlyer.logEvent(
        mockInAppEvent.type,
        mockInAppEvent.properties,
      )).called(1);
    });

    test('optOut is true', () {
      marketingAnalyticsService.optOut(true);
      verify(appsFlyer.stop(true)).called(1);
      verify(appsFlyer.enableLocationCollection(false)).called(1);
    });

    test('optOut is false', () {
      marketingAnalyticsService.optOut(false);
      verify(appsFlyer.stop(false)).called(1);
      verify(appsFlyer.enableLocationCollection(true)).called(1);
    });

    test('setCurrentDeviceLanguage', () {
      marketingAnalyticsService.setCurrentDeviceLanguage(mockLanguage);
      verify(appsFlyer.setCurrentDeviceLanguage(mockLanguage)).called(1);
    });
  });
}
