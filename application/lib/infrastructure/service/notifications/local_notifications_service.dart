import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_data.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

const String kChannelKey = 'basic_channel';
const String kAndroidIconPath = 'resource://drawable/res_app_icon';

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

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  LocalNotificationsServiceImpl(this._deepLinkManager) {
    _init();
  }

  void _init() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings(kAndroidIconPath);

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
    }
  }

  @override
  void openNotificationsPage() {
    //TODO: implement this
  }

  @override
  Future<void> sendNotification({
    required String body,
    required UniqueId documentId,
    Uri? image,
  }) async {
    final androidNotificationDetails = AndroidNotificationDetails(
      kChannelKey,
      R.strings.notificationsChannelName,
      channelDescription: R.strings.notificationsChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOS = DarwinNotificationDetails();

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
