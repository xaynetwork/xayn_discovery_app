import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@lazySingleton
class SetAppRatingAlreadyVisibleUseCase extends UseCase<None, None> {
  final AppStatusRepository _repository;
  bool _didUpdateThisSession = false;

  SetAppRatingAlreadyVisibleUseCase(this._repository);

  @override
  Stream<None> transaction(param) async* {
    if (!_didUpdateThisSession) {
      _didUpdateThisSession = true;

      final appStatus = _repository.appStatus;
      final updatedAppStatus =
          appStatus.copyWith(ratingDialogAlreadyVisible: true);
      _repository.save(updatedAppStatus);
    }

    yield none;
  }
}
