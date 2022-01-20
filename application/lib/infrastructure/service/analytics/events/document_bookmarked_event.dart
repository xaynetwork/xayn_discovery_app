import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentBookmarked';
const String _kParamDocument = 'document';
const String _kParamIsBookmarked = 'isBookmarked';

class DocumentBookmarkedEvent extends AnalyticsEvent {
  DocumentBookmarkedEvent({
    Document? previous,
    required Document document,
    required bool isBookmarked,
  }) : super(
          _kEventType,
          properties: {
            _kParamDocument: document,
            _kParamIsBookmarked: isBookmarked,
          },
        );
}
