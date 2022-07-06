import 'package:xayn_discovery_app/domain/model/analytics/analytics_document_extension.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/analytics/feed_analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentFeedbackChanged';
const String _kParamDocument = 'document';
const String _kParamContext = 'context';

/// An [AnalyticsEvent] which tracks when a [Document]'s feedback was changed'.
/// - [document] is the target [Document].
///
/// The document must already have [Document.feedback] updated, as the full
/// document will be logged in the event.
class DocumentFeedbackChangedEvent extends FeedAnalyticsEvent {
  final Document document;
  final FeedbackContext context;
  final FeedType? feedType;

  DocumentFeedbackChangedEvent({
    required this.document,
    required this.context,
    required this.feedType,
  }) : super(
          _kEventType,
          feedType: feedType,
          properties: {
            _kParamDocument: document.toAnalyticsJson(),
            _kParamContext: context.name,
          },
        );
}
