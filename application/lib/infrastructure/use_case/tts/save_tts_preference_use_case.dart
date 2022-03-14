import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class SaveTtsPreferenceUseCase extends UseCase<bool, bool> {
  final AppSettingsRepository _repository;

  SaveTtsPreferenceUseCase(this._repository);

  @override
  Stream<bool> transaction(bool param) async* {
    final settings = _repository.settings;
    final updatedSettings = settings.copyWith(autoPlayTextToSpeech: param);
    _repository.save(updatedSettings);
    yield param;
  }
}
