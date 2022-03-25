import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_analytics_service.dart';

@injectable
class SendMarketingAnalyticsUseCase
    extends UseCase<AnalyticsEvent, AnalyticsEvent> {
  final MarketingAnalyticsService _marketingAnalyticsService;

  SendMarketingAnalyticsUseCase(
      MarketingAnalyticsService marketingAnalyticsService)
      : _marketingAnalyticsService = marketingAnalyticsService;

  @override
  Stream<AnalyticsEvent> transaction(AnalyticsEvent param) async* {
    _marketingAnalyticsService.send(param);

    yield param;
  }
}
