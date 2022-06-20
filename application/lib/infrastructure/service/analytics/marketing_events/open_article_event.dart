import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'af_openArticle';

class OpenArticleMarketingEvent extends AnalyticsEvent {
  OpenArticleMarketingEvent() : super(_kEventType);
}
