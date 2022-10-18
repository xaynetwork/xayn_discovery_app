import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/local_notifications_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/remote_notifications_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/are_local_notifications_allowed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/get_push_notifications_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/save_push_notifications_status_use_case.dart';

@injectable
class TogglePushNotificationsStatusUseCase extends UseCase<None, None> {
  final LocalNotificationsService _localNotificationsService;
  final RemoteNotificationsService _remoteNotificationsService;
  final GetPushNotificationsStatusUseCase _getPushNotificationsStatusUseCase;
  final SavePushNotificationsStatusUseCase _savePushNotificationsStatusUseCase;
  final AreLocalNotificationsAllowedUseCase
      _areLocalNotificationsAllowedUseCase;

  TogglePushNotificationsStatusUseCase(
    this._localNotificationsService,
    this._remoteNotificationsService,
    this._getPushNotificationsStatusUseCase,
    this._savePushNotificationsStatusUseCase,
    this._areLocalNotificationsAllowedUseCase,
  );

  @override
  Stream<None> transaction(param) async* {
    final userDidChangePushNotifications =
        await _getPushNotificationsStatusUseCase.singleOutput(none);
    final isNotificationAllowed =
        await _areLocalNotificationsAllowedUseCase.singleOutput(none);

    // If the user tapped on the don't allow button on the native dialog,
    // and tries to toggle push notifications, redirect them to Settings
    if (userDidChangePushNotifications && !isNotificationAllowed) {
      _localNotificationsService.openNotificationsPage();
      yield none;
      return;
    } else if (!userDidChangePushNotifications) {
      await _savePushNotificationsStatusUseCase(none);
    }

    final arePushNotificationsActive =
        await _remoteNotificationsService.userNotificationsEnabled ?? false;
    if (arePushNotificationsActive) {
      await _remoteNotificationsService.disableNotifications();
    } else {
      // final result = await _localNotificationsService.requestPermission();
      // print(result);
      await _remoteNotificationsService.enableNotifications();
    }

    yield none;
  }
}
