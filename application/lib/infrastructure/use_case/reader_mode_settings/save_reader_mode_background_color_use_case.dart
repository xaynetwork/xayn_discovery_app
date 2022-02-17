import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';

@injectable
class SaveReaderModeBackgroundColorUseCase
    extends UseCase<ReaderModeBackgroundColor, ReaderModeBackgroundColor> {
  final ReaderModeSettingsRepository _repository;

  SaveReaderModeBackgroundColorUseCase(this._repository);

  @override
  Stream<ReaderModeBackgroundColor> transaction(
      ReaderModeBackgroundColor param) async* {
    final settings = _repository.settings;
    final updateSettings = settings.copyWith(backgroundColor: param);
    _repository.save(updateSettings);
    yield param;
  }
}
