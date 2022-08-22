import 'package:xayn_discovery_app/infrastructure/service/notifications/local_notifications_service.dart';

class RemoteNotification {
  final Map<String, dynamic>? payload;

  bool get isLocalNotification => payload?['channelKey'] == kChannelKey;

  RemoteNotification(this.payload);
}
