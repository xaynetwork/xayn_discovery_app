import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/concepts/navigation/page_data.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_screen_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/screen_time_spent_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';

@lazySingleton
class AnalyticsNavigatorObserver {
  final AppNavigationManager _appNavigationManager;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;

  AnalyticsNavigatorObserver(
    this._appNavigationManager,
    this._sendAnalyticsUseCase,
  ) {
    _init();
  }

  void _init() {
    _appNavigationManager.stream
        .map((event) => event.pages.last)
        .startWith(_appNavigationManager.initialPage)
        .doOnData(_sendOpenScreenEvent)
        .timestamp()
        .pairwise()
        .map(_calculateScreenTimeSpent)
        .listen(_sendAnalyticsUseCase);
  }

  _sendOpenScreenEvent(PageData page) {
    final event = OpenScreenEvent(
      screenName: page.name,
      arguments: page.arguments,
    );
    _sendAnalyticsUseCase(event);
  }

  ScreenTimeSpentEvent _calculateScreenTimeSpent(
    Iterable<Timestamped<PageData>> pair,
  ) {
    final screen = pair.first.value;
    final openTimestamp = pair.first.timestamp;
    final closeTimestamp = pair.last.timestamp;
    final duration = closeTimestamp.difference(openTimestamp);
    return ScreenTimeSpentEvent(
      screenName: screen.name,
      arguments: screen.arguments,
      duration: duration,
    );
  }
}
