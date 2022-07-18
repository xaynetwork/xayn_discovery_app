import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/service/background_fetch/background_engine_fetch_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/local_notifications_service.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class BackgroundNotificationsUseCase extends UseCase<None, None> {
  final LocalNotificationsService _localNotificationsService;
  late final BackgroundEngineFetchService _backgroundEngineFetchService;

  BackgroundNotificationsUseCase(
    this._localNotificationsService,
  ) {
    _backgroundEngineFetchService =
        BackgroundEngineFetchServiceImpl(_sendLocalNotificationIfNeeded);
  }

  void _sendLocalNotificationIfNeeded(EngineEvent engineEvent) {
    if (engineEvent is! NextFeedBatchRequestSucceeded) {
      logger.i('[BackgroundNotifications] Engine event: $engineEvent');
      return;
    }
    if (engineEvent.items.isEmpty) {
      logger.i('[BackgroundNotifications] No documents');
      return;
    }

    final document = engineEvent.items.first;

    _localNotificationsService.sendNotification(
      title: document.resource.title,
      body: document.resource.snippet,
      documentId: UniqueId.fromTrustedString(document.documentId.toString()),
      delay: Duration.zero,
    );
  }

  @override
  Stream<None> transaction(None param) async* {
    final allowed = await _localNotificationsService.isNotificationAllowed();
    if (!allowed) {
      logger.i('[BackgroundNotifications] Notifications not allowed.');
      return;
    }

    var status = await _backgroundEngineFetchService.getStatus();
    if (status != BackgroundEngineFetchStatus.available) {
      logger
          .i('[BackgroundNotifications] Engine fetch current status: $status');
      return;
    }

    status = await _backgroundEngineFetchService.configureAndStart();
    logger
        .i('[BackgroundNotifications] Engine fetch configure status: $status');
  }
}
