import 'package:xayn_discovery_app/domain/model/app_status.dart';

/// Repository interface for storing global app settings.
abstract class AppStatusRepository {
  /// The [AppStatus] setter method.
  void save(AppStatus appStatus);

  /// The [AppStatus] getter method.
  AppStatus get appStatus;
}
