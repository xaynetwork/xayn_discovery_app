import 'package:airship_flutter/airship_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class PushNotifications {
  PushNotifications._();

  static void setup() {
    setupRemote();
    setupLocal();
  }

  static void pushMessageHandler(PushReceivedEvent event) async {
    // Load news

    // Send local notification
    PushNotifications.sendLocal();
  }

  static void setupRemote() async {
    // Enable notifications (prompts on iOS)
    Airship.setUserNotificationsEnabled(true);

    // Channel ID
    final channelId = await Airship.channelId;
    // ignore: avoid_print
    print('channelId: $channelId');

    Airship.onPushReceived.listen(pushMessageHandler);
  }

  static void setupLocal() async {
    AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        'resource://drawable/res_app_icon',
        [
          NotificationChannel(
            channelKey: 'basic_channel',
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

  static void sendLocal() {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: 'Simple Notification',
            body: 'Simple body'));
  }
}
