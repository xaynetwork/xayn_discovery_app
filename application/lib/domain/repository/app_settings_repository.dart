import 'package:xayn_discovery_app/domain/model/app_settings.dart';

abstract class AppSettingsRepository {
  Future<void> save(AppSettings appSettings);
  Future<AppSettings> getSettings();
}
