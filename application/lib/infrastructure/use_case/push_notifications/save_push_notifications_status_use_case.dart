import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class SavePushNotificationsStatusUseCase extends UseCase<None, None> {
  final AppStatusRepository _repository;

  SavePushNotificationsStatusUseCase(this._repository);

  @override
  Stream<None> transaction(param) async* {
    final appStatus = _repository.appStatus;
    final updatedAppStatus =
        appStatus.copyWith(userDidChangePushNotificationsStatus: true);
    _repository.save(updatedAppStatus);
    yield none;
  }
}
