import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';

@injectable
class SaveReaderModeFontStyleUseCase
    extends UseCase<ReaderModeFontStyle, ReaderModeFontStyle> {
  final ReaderModeSettingsRepository _repository;

  SaveReaderModeFontStyleUseCase(this._repository);

  @override
  Stream<ReaderModeFontStyle> transaction(ReaderModeFontStyle param) async* {
    final settings = _repository.settings;
    final updateSettings = settings.copyWith(readerModeFontStyle: param);
    _repository.save(updateSettings);
    yield param;
  }
}
