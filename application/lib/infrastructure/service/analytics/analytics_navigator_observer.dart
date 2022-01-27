import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_screen_event.dart';
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
        .map((it) => OpenScreenEvent(
              screenName: it.name,
              arguments: it.arguments,
            ))
        .listen(_sendAnalyticsUseCase);
  }
}
