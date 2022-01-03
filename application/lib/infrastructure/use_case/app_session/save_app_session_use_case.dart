import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class SaveAppSessionUseCase extends UseCase<int, None> {
  final AppSettingsRepository _repository;

  SaveAppSessionUseCase(this._repository);

  @override
  Stream<None> transaction(int param) async* {
    final settings = _repository.settings;
    final updatedSettings = settings.copyWith(numberOfSessions: param);
    _repository.settings = updatedSettings;
    yield none;
  }
}
