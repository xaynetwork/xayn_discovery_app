import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class SaveAppVersionUseCase extends UseCase<AppVersion, None> {
  final AppStatusRepository _repository;

  SaveAppVersionUseCase(this._repository);

  @override
  Stream<None> transaction(AppVersion param) async* {
    final appStatus = _repository.appStatus;
    final updatedAppStatus = appStatus.copyWith(lastKnownAppVersion: param);
    _repository.appStatus = updatedAppStatus;
    yield none;
  }
}
