import 'package:airship_flutter/airship_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kChannelKey = 'basic_channel';

@lazySingleton
class PushNotificationsService {
  final DiscoveryEngine _engine;

  PushNotificationsService(
    this._engine,
  ) {
    _setupRemote();
    _setupLocal();
  }

  void _pushMessageHandler(PushReceivedEvent event) async {
    // ignore: avoid_print
    print('Notification received');

    final event = await _engine.requestNextFeedBatch();
    if (event is! NextFeedBatchRequestSucceeded) {
      // ignore: avoid_print
      print('Engine event: $event');
      return;
    }
    if (event.items.isEmpty) {
      // ignore: avoid_print
      print('No documents');
      return;
    }
    final document = event.items.first;

    // ignore: avoid_print
    print('Latest news: ${document.resource.title}');
    _sendLocal(
      title: document.resource.title,
      body: document.resource.snippet,
    );
  }

  void _setupRemote() async {
    // Enable notifications (prompts on iOS)
    Airship.setUserNotificationsEnabled(true);

    Airship.onChannelRegistration.listen((event) =>
        // ignore: avoid_print
        print('Channel Registration, channelId: ${event.channelId}'));

    // Channel ID
    final channelId = await Airship.channelId;
    // ignore: avoid_print
    print('channelId: $channelId');

    Airship.onPushReceived.listen(_pushMessageHandler);
  }

  void _setupLocal() async {
    AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: _kChannelKey,
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
          )
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupkey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: true);

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    AwesomeNotifications()
        .actionStream
        .listen((ReceivedNotification receivedNotification) {});
  }

  void _sendLocal({
    required String title,
    required String body,
  }) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: _kChannelKey,
        title: title,
        body: body,
      ),
    );
  }
}
