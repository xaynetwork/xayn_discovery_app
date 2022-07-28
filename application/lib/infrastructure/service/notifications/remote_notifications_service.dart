import 'dart:async';

import 'package:airship_flutter/airship_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/remote_notification.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

abstract class RemoteNotificationsService {
  Stream<RemoteNotification> get notificationStream;
  Future<void> enableNotifications();
  Future<void> disableNotifications();
  Future<void> clearNotifications();
}

@LazySingleton(as: RemoteNotificationsService)
class RemoteNotificationsServiceImpl implements RemoteNotificationsService {
  final StreamController<RemoteNotification> _controller =
      StreamController<RemoteNotification>.broadcast();

  @override
  Stream<RemoteNotification> get notificationStream => _controller.stream;

  RemoteNotificationsServiceImpl() {
    _init();
  }

  void _init() async {
    // await enableNotifications();

    final channelId = await Airship.channelId;
    logger.i('[Remote notifications] Current channel ID: $channelId');

    Airship.onChannelRegistration.listen(_channelCreatedHandler);
    Airship.onPushReceived.listen(_pushMessageHandler);
  }

  void _channelCreatedHandler(ChannelEvent event) {
    logger.i('[Remote notifications] Channel created: $event');
  }

  void _pushMessageHandler(PushReceivedEvent event) {
    logger.i('[Remote notifications] Notification received: $event');
    final notification = RemoteNotification(event.payload);
    _controller.add(notification);
  }

  @override
  Future<void> enableNotifications() =>
      Airship.setUserNotificationsEnabled(true);

  @override
  Future<void> disableNotifications() =>
      Airship.setUserNotificationsEnabled(false);

  @override
  Future<void> clearNotifications() => Airship.clearNotifications();
}
