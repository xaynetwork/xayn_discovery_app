import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

import '../../../presentation/test_utils/fakes.dart';

class FakeAnalyticsEvent implements AnalyticsEvent {
  @override
  Map<String, dynamic> get properties => {'unique_id': fakeBookmark.id};

  @override
  String get type => 'fake_event';
}
