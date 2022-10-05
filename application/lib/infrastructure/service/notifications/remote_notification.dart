import 'package:xayn_discovery_app/presentation/constants/r.dart';

const String kTitleKey = 'title';

class RemoteNotification {
  final Map<String, dynamic>? payload;

  bool get isLocalNotification =>
      payload?[kTitleKey] == R.strings.notificationTitle;

  RemoteNotification(this.payload);
}
