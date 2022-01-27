import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

@lazySingleton
class UrlOpener {
  late final LogUseCase<Uri> _openUrlLogUseCase = LogUseCase<Uri>(
    (it) => 'Could not launch $it',
    logger: logger,
  );

  void openUrl(String url) async {
    final uri = Uri.tryParse(url);
    assert(
      uri != null && uri.hasAuthority,
      'Please pass valid url. Current: $url',
    );

    if (!await launch(uri.toString())) {
      _openUrlLogUseCase.call(uri!);
    }
  }
}
