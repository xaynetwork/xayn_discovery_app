import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class GetStoredAppVersionUseCase extends UseCase<None, AppVersion> {
  final AppSettingsRepository _repository;

  GetStoredAppVersionUseCase(this._repository);

  @override
  Stream<AppVersion> transaction(None param) async* {
    yield _repository.settings.appVersion;
  }
}
