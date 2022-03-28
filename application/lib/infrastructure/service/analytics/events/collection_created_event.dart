import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'collectionCreated';

class CollectionCreatedEvent extends AnalyticsEvent {
  CollectionCreatedEvent() : super(_kEventType);
}
