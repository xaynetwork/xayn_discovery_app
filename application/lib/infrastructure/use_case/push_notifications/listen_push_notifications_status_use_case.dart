import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class ListenPushNotificationsStatusUseCase extends UseCase<None, bool> {
  final AppStatusRepository _repository;

  ListenPushNotificationsStatusUseCase(this._repository);

  @override
  Stream<bool> transaction(None param) {
    return _repository
        .watch()
        .map((_) => _repository.appStatus.userDidChangePushNotificationsStatus)
        .distinct();
  }
}
