import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/document_id_payload_mapper.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_data.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_manager.dart';

const String _kChannelKey = 'basic_channel';
const String _channelName = 'Basic notifications';
const String _channelDescription = 'Notification channel for basic tests';

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
            channelName: _channelName,
            channelDescription: _channelDescription,
          )
        ],
        debug: true);

    AwesomeNotifications().actionStream.listen(_deepLinkHandler);
  }

  void _deepLinkHandler(ReceivedNotification receivedNotification) {
    final payload = receivedNotification.payload;
    if (payload == null) return;
    final documentId = _payloadToDocumentIdMapper.map(payload);
    if (documentId == null) return;
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
