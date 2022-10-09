import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/save_notification_image_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_data.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

const String kChannelKey = 'basic_channel';
const String kAndroidIconName = 'res_app_icon';

abstract class LocalNotificationsService {
  void requestPermission();
  void openNotificationsPage();
  Future<void> sendNotification({
    required String body,
    required UniqueId documentId,
    Uri? image,
  });
  Future<bool> get isNotificationAllowed;
}

@LazySingleton(as: LocalNotificationsService)
class LocalNotificationsServiceImpl implements LocalNotificationsService {
  final DeepLinkManager _deepLinkManager;
  final SaveNotificationImageUseCase _saveNotificationImageUseCase;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  LocalNotificationsServiceImpl(
    this._deepLinkManager,
    this._saveNotificationImageUseCase,
  ) {
    _init();
  }

  void _init() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings(kAndroidIconName);

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    logger.i('[Local Notifications] Did receive notification response.');

    final String? payload = notificationResponse.payload;
    if (payload == null) {
      logger.i('[Local Notifications] Payload not set.');
      return;
    }
    final documentId = UniqueId.fromTrustedString(payload);
    final deepLinkData = DeepLinkData.feed(documentId: documentId);
    _deepLinkManager.onDeepLink(deepLinkData);
  }

  @override
  Future<bool> get isNotificationAllowed async {
    final permissionStatus =
        await NotificationPermissions.getNotificationPermissionStatus();
    return permissionStatus == PermissionStatus.granted;
  }

  @override
  void requestPermission() async {
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    } else if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    }
  }

  @override
  void openNotificationsPage() => AppSettings.openNotificationSettings();

  @override
  Future<void> sendNotification({
    required String body,
    required UniqueId documentId,
    Uri? image,
  }) async {
    logger.i('[Local Notifications] Sending notification.');

    final imagePath = await _saveNotificationImageUseCase.singleOutput(image);

    final androidNotificationDetails = AndroidNotificationDetails(
      kChannelKey,
      R.strings.notificationsChannelName,
      channelDescription: R.strings.notificationsChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: imagePath != null ? FilePathAndroidBitmap(imagePath) : null,
    );

    final iOS = DarwinNotificationDetails(
      attachments:
          imagePath != null ? [DarwinNotificationAttachment(imagePath)] : null,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOS,
    );

    return _flutterLocalNotificationsPlugin.show(
      0,
      R.strings.notificationTitle,
      body,
      notificationDetails,
      payload: documentId.value,
    );
  }
}
