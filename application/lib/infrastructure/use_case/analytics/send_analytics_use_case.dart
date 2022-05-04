import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_bookmarked_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_feedback_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_events/bookmark_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_events/interaction_event.dart';

@injectable
class SendAnalyticsUseCase extends UseCase<AnalyticsEvent, AnalyticsEvent> {
  final AnalyticsService _analyticsService;
  final MarketingAnalyticsService _marketingAnalyticsService;

  SendAnalyticsUseCase(
    AnalyticsService analyticsService,
    MarketingAnalyticsService marketingAnalyticsService,
  )   : _analyticsService = analyticsService,
        _marketingAnalyticsService = marketingAnalyticsService;

  @override
  Stream<AnalyticsEvent> transaction(AnalyticsEvent param) async* {
    await _analyticsService.send(param);
    _maybeSendMarketingAnalytics(param);
    yield param;
  }

  /// We send duplicate events to the marketing analytics platform to analyze conversion metrics
  void _maybeSendMarketingAnalytics(AnalyticsEvent event) {
    if (event is DocumentBookmarkedEvent && event.isBookmarked) {
      _marketingAnalyticsService.send(BookmarkMarketingEvent());
    } else if (event is DocumentFeedbackChangedEvent &&
        event.context == FeedbackContext.explicit) {
      _marketingAnalyticsService.send(
        InteractionMarketingEvent(
          interaction: event.document.userReaction,
        ),
      );
    }
  }
}
