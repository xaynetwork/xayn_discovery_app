import 'package:airship_flutter/airship_flutter.dart';

class PushNotifications {
  PushNotifications._();

  static void pushMessageHandler(PushReceivedEvent event) async {
    // Handle the message
  }

  static void setup() async {
    // Enable notifications (prompts on iOS)
    Airship.setUserNotificationsEnabled(true);

    // Channel ID
    final channelId = await Airship.channelId;
    // ignore: avoid_print
    print('channelId: $channelId');

    Airship.onPushReceived.listen(pushMessageHandler);
  }
}
