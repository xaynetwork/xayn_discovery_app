import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';

/// Repository interface for storing global app settings.
abstract class AppStatusRepository {
  /// The [AppStatus] setter method.
  set appStatus(AppStatus appStatus);

  /// The [AppStatus] getter method.
  AppStatus get appStatus;

  /// A stream of [RepositoryEvent]. Emits when [AppStatus] changes.
  Stream<RepositoryEvent<AppStatus>> watch();
}
