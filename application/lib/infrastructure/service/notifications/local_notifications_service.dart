import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/document_id_payload_mapper.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_data.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

const String kChannelKey = 'basic_channel';
const String kAndroidIconPath = 'resource://drawable/res_app_icon';

abstract class LocalNotificationsService {
  void requestPermission();

  Future<bool> sendNotification({
    required String body,
    required UniqueId documentId,
    required Duration delay,
    Uri? image,
  });
}

@LazySingleton(as: LocalNotificationsService)
class LocalNotificationsServiceImpl implements LocalNotificationsService {
  final DeepLinkManager _deepLinkManager;
  final DocumentIdToPayloadMapper _documentIdToPayloadMapper;
  final PayloadToDocumentIdMapper _payloadToDocumentIdMapper;

  LocalNotificationsServiceImpl(
    this._deepLinkManager,
    this._documentIdToPayloadMapper,
    this._payloadToDocumentIdMapper,
  ) {
    _init();
  }

  void _init() {
    AwesomeNotifications().initialize(
        kAndroidIconPath,
        [
          NotificationChannel(
            channelKey: kChannelKey,
            channelName: R.strings.notificationsChannelName,
            channelDescription: R.strings.notificationsChannelDescription,
          )
        ],
        debug: EnvironmentHelper.kIsDebug);

    AwesomeNotifications().actionStream.listen(_deepLinkHandler);
  }

  void _deepLinkHandler(ReceivedNotification receivedNotification) {
    final payload = receivedNotification.payload;
    if (payload == null) {
      logger.i('[Local Notifications] Payload not set.');
      return;
    }
    final documentId = _payloadToDocumentIdMapper.map(payload);
    if (documentId == null) {
      logger.i(
          '[Local Notifications] documentId not found in notification payload.');
      return;
    }
    final deepLinkData = DeepLinkData.feed(documentId: documentId);
    _deepLinkManager.onDeepLink(deepLinkData);
  }

  @override
  void requestPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  Future<bool> sendNotification({
    required String body,
    required UniqueId documentId,
    required Duration delay,
    Uri? image,
  }) {
    final scheduleTime = DateTime.now().add(delay);
    return AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: kChannelKey,
        title: R.strings.notificationTitle,
        body: body,
        payload: _documentIdToPayloadMapper.map(documentId),
        bigPicture: image?.toString(),
        notificationLayout:
            image != null ? NotificationLayout.BigPicture : null,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduleTime),
    );
  }
}
