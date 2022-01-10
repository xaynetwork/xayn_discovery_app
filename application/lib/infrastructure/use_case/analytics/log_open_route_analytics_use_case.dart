import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/navigation/page_data.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_screen_analytics_event.dart';

/// Listen to navigation changes and log [AnalyticsEvents].
@lazySingleton
class LogOpenRouteAnalyticsUseCase extends UseCase<PageData, PageData> {
  final AnalyticsService _analyticsService;

  LogOpenRouteAnalyticsUseCase(this._analyticsService);

  @override
  Stream<PageData> transaction(PageData param) {
    final event = OpenScreenAnalyticsEvent(param.name, param.arguments);
    _analyticsService.logEvent(event);
    return Stream.value(param);
  }
}
