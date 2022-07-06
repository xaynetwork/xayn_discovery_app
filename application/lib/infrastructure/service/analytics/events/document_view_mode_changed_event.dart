import 'package:xayn_discovery_app/domain/model/analytics/analytics_document_extension.dart';
import 'package:xayn_discovery_app/domain/model/analytics/feed_analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentViewModeChanged';
const String _kParamViewMode = 'viewMode';
const String _kParamDocument = 'document';

/// An [FeedAnalyticsEvent] which tracks when a card switches view mode between story and reader.
/// - [document] is the target [Document].
/// - [viewMode] indicates the mode, story or reader.
/// - [feedType] indicates the current screen the event was triggered from.
class DocumentViewModeChangedEvent extends FeedAnalyticsEvent {
  final Document document;
  final DocumentViewMode viewMode;
  final FeedType feedType;

  DocumentViewModeChangedEvent({
    required this.document,
    required this.viewMode,
    required this.feedType,
  }) : super(
          _kEventType,
          feedType: feedType,
          properties: {
            _kParamViewMode: viewMode.name,
            _kParamDocument: document.toAnalyticsJson(),
          },
        );
}
