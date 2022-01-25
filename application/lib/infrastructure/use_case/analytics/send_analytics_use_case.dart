import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';

@injectable
class SendAnalyticsUseCase extends UseCase<AnalyticsEvent, AnalyticsEvent> {
  final AnalyticsService _analyticsService;

  SendAnalyticsUseCase(AnalyticsService analyticsService)
      : _analyticsService = analyticsService;

  @override
  Stream<AnalyticsEvent> transaction(AnalyticsEvent param) async* {
    await _analyticsService.send(param);

    yield param;
  }
}
