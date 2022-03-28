import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentBookmarked';
const String _kParamDocument = 'document';
const String _kParamIsBookmarked = 'isBookmarked';
const String _kParamToDefaultCollection = 'toDefaultCollection';

/// An [AnalyticsEvent] which tracks when a [Document] was bookmarked, or not.
/// - [document] is the target [Document].
/// - [isBookmarked] is true when bookmarked, false when not.
class DocumentBookmarkedEvent extends AnalyticsEvent {
  DocumentBookmarkedEvent({
    Document? previous,
    required Document document,
    required bool isBookmarked,
    required bool toDefaultCollection,
  }) : super(
          _kEventType,
          properties: {
            _kParamDocument: document.toJson(),
            _kParamIsBookmarked: isBookmarked,
            _kParamToDefaultCollection: toDefaultCollection,
          },
        );
}
