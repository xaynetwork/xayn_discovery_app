import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/concepts/navigation/page_data.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_screen_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/screen_time_spent_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';

@lazySingleton
class AnalyticsNavigatorObserver {
  final AppManager _appManager;
  final AppNavigationManager _appNavigationManager;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;

  AnalyticsNavigatorObserver(
    this._appManager,
    this._appNavigationManager,
    this._sendAnalyticsUseCase,
  ) {
    _init();
  }

  void _init() {
    wrappedPageData(bool isPaused) {
      final stream = isPaused
          ? Stream.value(_appNavigationManager.state.pages.last)
          : _appNavigationManager.stream
              .map((it) => it.pages.last)
              .startWith(_appNavigationManager.state.pages.last);

      return stream.map((it) => _PauseAwarePageData(
            pageData: it,
            isPaused: isPaused,
          ));
    }

    _appManager.stream
        .map((it) => it.isAppPaused)
        .switchMap(wrappedPageData) // switch over to wrapped page data
        .doOnData(_maybeSendOpenScreenEvent) // only when not paused
        .timestamp()
        .pairwise()
        .where((it) => !it.first.value.isPaused) // ignore when isPaused
        .map(_calculateScreenTimeSpent)
        .listen(_sendAnalyticsUseCase);
  }

  _maybeSendOpenScreenEvent(_PauseAwarePageData wrapper) {
    if (wrapper.isPaused) return;

    final event = OpenScreenEvent(
      screenName: wrapper.pageData.name,
      arguments: wrapper.pageData.arguments,
    );

    _sendAnalyticsUseCase(event);
  }

  ScreenTimeSpentEvent _calculateScreenTimeSpent(
    Iterable<Timestamped<_PauseAwarePageData>> pair,
  ) {
    final wrapper = pair.first.value;
    final openTimestamp = pair.first.timestamp;
    final closeTimestamp = pair.last.timestamp;
    final duration = closeTimestamp.difference(openTimestamp);

    return ScreenTimeSpentEvent(
      screenName: wrapper.pageData.name,
      arguments: wrapper.pageData.arguments,
      duration: duration,
    );
  }
}

class _PauseAwarePageData {
  final bool isPaused;
  final PageData pageData;

  const _PauseAwarePageData({
    required this.pageData,
    required this.isPaused,
  });
}
