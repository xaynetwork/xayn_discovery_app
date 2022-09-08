import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class GetPushNotificationsStatusUseCase extends UseCase<None, bool> {
  final AppStatusRepository _repository;

  GetPushNotificationsStatusUseCase(this._repository);

  @override
  Stream<bool> transaction(None param) async* {
    yield _repository.appStatus.userDidChangePushNotificationsStatus;
  }
}
