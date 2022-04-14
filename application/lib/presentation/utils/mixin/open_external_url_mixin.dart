import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';

mixin OpenExternalUrlMixin<T> on UseCaseBlocHelper<T> {
  final _sendAnalyticsUseCase = di.get<SendAnalyticsUseCase>();
  final _urlOpener = di.get<UrlOpener>();

  void openExternalUrl({
    required String url,
    required CurrentView currentView,
    FeedType? feedType,
  }) {
    _urlOpener.openUrl(url);
    _sendAnalyticsUseCase(
      OpenExternalUrlEvent(
        url: url,
        currentView: currentView,
        feedType: feedType,
      ),
    );
  }

  void openExternalEmail(String email, CurrentView currentView) {
    _urlOpener.openEmail(email);
    _sendAnalyticsUseCase(
      OpenExternalUrlEvent(
        url: email,
        currentView: currentView,
      ),
    );
  }

  void openExternalTel(String tel, CurrentView currentView) {
    _urlOpener.openTel(tel);
    _sendAnalyticsUseCase(
      OpenExternalUrlEvent(url: tel, currentView: currentView),
    );
  }
}
