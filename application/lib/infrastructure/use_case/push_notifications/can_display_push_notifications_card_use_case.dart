import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/get_push_notifications_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

@injectable
class CanDisplayPushNotificationsCardUseCase extends UseCase<None, bool> {
  final GetPushNotificationsStatusUseCase _getPushNotificationsStatusUseCase;
  final FeatureManager _featureManager;

  CanDisplayPushNotificationsCardUseCase(
    this._getPushNotificationsStatusUseCase,
    this._featureManager,
  );

  @override
  Stream<bool> transaction(None param) async* {
    if (Platform.isAndroid || !_featureManager.areRemoteNotificationsEnabled) {
      yield false;
      return;
    }

    final userDidChangePushNotifications =
        await _getPushNotificationsStatusUseCase.singleOutput(none);
    yield userDidChangePushNotifications == false;
  }
}