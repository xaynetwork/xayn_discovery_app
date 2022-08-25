import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/local_notifications_service.dart';

class RemoteNotification {
  final Map<String, dynamic>? payload;

  bool get isLocalNotification =>
      payload?[NOTIFICATION_CHANNEL_KEY] == kChannelKey;

  RemoteNotification(this.payload);
}
