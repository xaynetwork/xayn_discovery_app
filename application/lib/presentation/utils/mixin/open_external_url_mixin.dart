import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';

mixin OpenExternalUrlMixin<T> on UseCaseBlocHelper<T> {
  final _urlOpener = di.get<UrlOpener>();

  void openExternalUrl({
    required String url,
    FeedType? feedType,
  }) {
    _urlOpener.openUrl(url);
  }

  void openExternalEmail(String email) => _urlOpener.openEmail(email);

  void openExternalTel(String tel) => _urlOpener.openTel(tel);
}
