import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';

abstract class AppSettingsRepository {
  Future<void> save(AppSettings appSettings);
  Future<AppSettings> get settings;
  Stream<RepositoryEvent<AppSettings>> watch();
}
