import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_screen_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockAnalyticsService analyticsService;
  late MockMarketingAnalyticsService marketingAnalyticsService;
  late SendAnalyticsUseCase useCase;
  final event = OpenScreenEvent(screenName: 'test');

  setUp(() {
    analyticsService = MockAnalyticsService();
    marketingAnalyticsService = MockMarketingAnalyticsService();
    useCase = SendAnalyticsUseCase(analyticsService, marketingAnalyticsService);

    when(analyticsService.send(any)).thenAnswer((_) async {});
  });

  useCaseTest<SendAnalyticsUseCase, AnalyticsEvent, AnalyticsEvent>(
    'WHEN calling the use case THEN the event is sent via the analytics service',
    build: () => useCase,
    input: [event],
    expect: [useCaseSuccess(event)],
    verify: (useCase) {
      verify(analyticsService.send(event));
      verifyNoMoreInteractions(analyticsService);
    },
  );
}
