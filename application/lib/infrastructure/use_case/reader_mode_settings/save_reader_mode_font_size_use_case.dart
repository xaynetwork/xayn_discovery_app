import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';

@injectable
class SaveReaderModeFontSizeUseCase
    extends UseCase<ReaderModeFontSize, ReaderModeFontSize> {
  final ReaderModeSettingsRepository _repository;

  SaveReaderModeFontSizeUseCase(this._repository);

  @override
  Stream<ReaderModeFontSize> transaction(ReaderModeFontSize param) async* {
    final settings = _repository.settings;
    final updateSettings = settings.copyWith(readerModeFontSize: param);
    _repository.save(updateSettings);
    yield param;
  }
}
