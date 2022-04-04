import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/concepts/navigation/page_data.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_screen_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/screen_time_spent_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_lifecycle/app_lifecycle_use_case.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/navigation/pages.dart';

@lazySingleton
class AnalyticsNavigatorObserver {
  final AppNavigationManager _appNavigationManager;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;
  final AppLifecycleUseCase _appLifecycleUseCase;

  AnalyticsNavigatorObserver(
    this._appNavigationManager,
    this._sendAnalyticsUseCase,
    this._appLifecycleUseCase,
  ) {
    _init();
  }

  void _init() {
    /// The pauseStream maps to 'PageRegistry.pause' when isPaused = true
    /// but also it should map to '_appNavigationManager.stream.pages.last'
    /// when isPaused = false
    final pauseStream = _appLifecycleUseCase.pauseStream
        .where((isPaused) => isPaused)
        .mapTo(PageRegistry.pause);

    _appNavigationManager.stream
        .map((event) => event.pages.last)
        .startWith(_appNavigationManager.initialPage)
        .doOnData(_sendOpenScreenEvent)
        .mergeWith([pauseStream])
        .timestamp()
        .pairwise()
        .where((pair) => pair.first.value != PageRegistry.pause)
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
