import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';

/// Repository interface for storing global app settings.
abstract class AppSettingsRepository {
  /// The [AppSettings] setter method.
  set settings(AppSettings appSettings);

  /// The [AppSettings] getter method.
  AppSettings get settings;

  /// A stream of [RepositoryEvent]. Emits when [AppSettings] changes.
  Stream<RepositoryEvent<AppSettings>> watch();
}
