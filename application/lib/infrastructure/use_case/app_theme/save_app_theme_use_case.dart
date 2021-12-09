import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class SaveAppThemeUseCase extends UseCase<AppTheme, None> {
  final AppSettingsRepository _repository;

  SaveAppThemeUseCase(this._repository);

  @override
  Stream<None> transaction(AppTheme param) async* {
    final settings = _repository.settings;
    final updatedSettings = settings.copyWith(appTheme: param);
    _repository.settings = updatedSettings;
    yield none;
  }
}
