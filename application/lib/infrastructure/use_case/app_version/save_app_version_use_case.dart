import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class SaveAppVersionUseCase extends UseCase<AppVersion, None> {
  final AppSettingsRepository _repository;

  SaveAppVersionUseCase(this._repository);

  @override
  Stream<None> transaction(AppVersion param) async* {
    final settings = _repository.settings;
    final updatedSettings = settings.copyWith(appVersion: param);
    _repository.settings = updatedSettings;
    yield none;
  }
}
