import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'collectionRenamed';

class CollectionRenamedEvent extends AnalyticsEvent {
  CollectionRenamedEvent() : super(_kEventType);
}
