import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';

mixin OpenExternalUrlMixin<T> on UseCaseBlocHelper<T> {
  final _sendAnalyticsUseCase = di.get<SendAnalyticsUseCase>();
  final _urlOpener = di.get<UrlOpener>();

  void openExternalUrl(String url, CurrentView currentView) {
    _urlOpener.openUrl(url);
    _sendAnalyticsUseCase(
      OpenExternalUrlEvent(
        url: url,
        currentView: currentView,
      ),
    );
  }
}
