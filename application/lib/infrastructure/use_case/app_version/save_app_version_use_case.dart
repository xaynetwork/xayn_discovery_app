import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class SaveCurrentAppVersion extends UseCase<None, None> {
  final AppStatusRepository _repository;
  final PackageInfo _info;

  SaveCurrentAppVersion(
    this._repository,
    this._info,
  );

  @override
  Stream<None> transaction(param) async* {
    final currentAppVersion = AppVersion.current(_info);
    final appStatus = _repository.appStatus;
    final updatedAppStatus =
        appStatus.copyWith(lastKnownAppVersion: currentAppVersion);
    _repository.appStatus = updatedAppStatus;
    yield none;
  }
}
