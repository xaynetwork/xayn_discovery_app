import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class SaveAppSessionUseCase extends UseCase<int, None> {
  final AppStatusRepository _repository;

  SaveAppSessionUseCase(this._repository);

  @override
  Stream<None> transaction(int param) async* {
    final appStatus = _repository.appStatus;
    final updatedAppStatus = appStatus.copyWith(numberOfSessions: param);
    _repository.appStatus = updatedAppStatus;
    yield none;
  }
}
