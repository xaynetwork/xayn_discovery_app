import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/log_open_route_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';

@lazySingleton
class AnalyticsNavigatorObserver {
  final AppNavigationManager _appNavigationManager;
  final LogOpenRouteAnalyticsUseCase _logOpenRouteUseCase;

  AnalyticsNavigatorObserver(
    this._appNavigationManager,
    this._logOpenRouteUseCase,
  ) {
    _init();
  }

  void _init() {
    _appNavigationManager.stream
        .map((event) => event.pages.last)
        .listen(_logOpenRouteUseCase.call);
  }
}
