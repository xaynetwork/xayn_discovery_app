import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

/// Repository interface for storing global app settings.
abstract class AppStatusRepository {
  /// The [AppStatus] setter method.
  void save(AppStatus appStatus);

  /// The [AppStatus] getter method.
  AppStatus get appStatus;

  Stream<RepositoryEvent> watch({UniqueId id});
}
