import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

abstract class AppSettingsRepository {
  Future<void> save(AppSettings appSettings);
  Future<AppSettings> getSettings();
  Stream<RepositoryEvent<AppSettings>> watch({UniqueId? id});
}
