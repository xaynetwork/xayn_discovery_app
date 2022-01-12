import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class GetAppSessionUseCase extends UseCase<None, int> {
  final AppStatusRepository _repository;

  GetAppSessionUseCase(this._repository);

  @override
  Stream<int> transaction(None param) async* {
    yield _repository.appStatus.numberOfSessions;
  }
}
