import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class GetUserIdUseCase extends UseCase<None, String> {
  final AppStatusRepository _repository;

  GetUserIdUseCase(this._repository);

  @override
  Stream<String> transaction(None param) async* {
    yield _repository.appStatus.userId.value;
  }
}
