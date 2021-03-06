import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/document_id_payload_mapper.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_data.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

const String _kChannelKey = 'basic_channel';

abstract class LocalNotificationsService {
  void requestPermission();
  Future<bool> sendNotification({
    required String title,
    required String body,
    required UniqueId documentId,
    required Duration delay,
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
        null,
        [
          NotificationChannel(
            channelKey: _kChannelKey,
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
      logger.i('Notification payload not set.');
      return;
    }
    final documentId = _payloadToDocumentIdMapper.map(payload);
    if (documentId == null) {
      logger.i('documentId not found in notification payload.');
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
    required String title,
    required String body,
    required UniqueId documentId,
    required Duration delay,
  }) {
    final scheduleTime = DateTime.now().add(delay);
    return AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: _kChannelKey,
        title: title,
        body: body,
        payload: _documentIdToPayloadMapper.map(documentId),
      ),
      schedule: NotificationCalendar.fromDate(date: scheduleTime),
    );
  }
}
