import 'dart:async';
import 'dart:io';

import 'package:airship_flutter/airship_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/remote_notification.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

abstract class RemoteNotificationsService {
  Stream<RemoteNotification> get notificationStream;
  Future<bool?> get userNotificationsEnabled;
  Future<bool?> enableNotifications();
  Future<bool?> disableNotifications();
  Future<String?> get channelId;
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
    final channelId = await Airship.channelId;
    logger.i('[Remote notifications] Current channel ID: $channelId');

    Airship.onChannelRegistration.listen(_channelCreatedHandler);
    Airship.onPushReceived.listen(_pushMessageHandler);

    if (Platform.isAndroid) enableNotifications();
  }

  void _channelCreatedHandler(ChannelEvent event) {
    logger.i('[Remote notifications] Channel created: $event');
  }

  void _pushMessageHandler(PushReceivedEvent event) async {
    final userNotificationsEnabled = await Airship.userNotificationsEnabled;
    logger.i('[Remote notifications] Notifications disabled.');

    if (userNotificationsEnabled == false) return;

    logger.i('[Remote notifications] Notification received: $event');
    final notification = RemoteNotification(event.payload);

    // Return if we receive a local notification to not emit notifications in a loop.
    if (notification.isLocalNotification) return;

    _controller.add(notification);
  }

  @override
  Future<bool?> get userNotificationsEnabled =>
      Airship.userNotificationsEnabled;

  @override
  Future<bool?> enableNotifications() =>
      Airship.setUserNotificationsEnabled(true);

  @override
  Future<bool?> disableNotifications() =>
      Airship.setUserNotificationsEnabled(false);

  @override
  Future<String?> get channelId => Airship.channelId;
}
