import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';

abstract class AppSettingsRepository {
  void save(AppSettings appSettings);
  AppSettings get settings;
  Stream<RepositoryEvent<AppSettings>> watch();
}
