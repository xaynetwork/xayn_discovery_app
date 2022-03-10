import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class GetTtsPreferenceUseCase extends UseCase<None, bool> {
  final AppSettingsRepository _repository;

  GetTtsPreferenceUseCase(this._repository);

  @override
  Stream<bool> transaction(None param) async* {
    yield _repository.settings.autoPlayTextToSpeech;
  }
}
