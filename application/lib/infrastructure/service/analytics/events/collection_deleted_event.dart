import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'collectionDeleted';
const String _kContext = 'deleteCollectionContext';

enum DeleteCollectionContext {
  moveBookmarks,
  deleteBookmarks,
  empty,
}

class CollectionDeletedEvent extends AnalyticsEvent {
  CollectionDeletedEvent({
    required DeleteCollectionContext context,
  }) : super(
          _kEventType,
          properties: {
            _kContext: context.name,
          },
        );
}
