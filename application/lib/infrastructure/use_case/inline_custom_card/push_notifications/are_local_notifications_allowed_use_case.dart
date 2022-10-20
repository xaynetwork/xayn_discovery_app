import 'package:injectable/injectable.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';

@injectable
class AreLocalNotificationsAllowedUseCase extends UseCase<None, bool> {
  AreLocalNotificationsAllowedUseCase();

  @override
  Stream<bool> transaction(None param) async* {
    final permissionStatus =
        await NotificationPermissions.getNotificationPermissionStatus();
    yield permissionStatus == PermissionStatus.granted;
  }
}
