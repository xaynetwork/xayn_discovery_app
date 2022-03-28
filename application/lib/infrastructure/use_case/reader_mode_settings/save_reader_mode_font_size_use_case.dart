import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size_param.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';

@injectable
class SaveReaderModeFontSizeParamUseCase
    extends UseCase<ReaderModeFontSizeParam, ReaderModeFontSizeParam> {
  final ReaderModeSettingsRepository _repository;

  SaveReaderModeFontSizeParamUseCase(this._repository);

  @override
  Stream<ReaderModeFontSizeParam> transaction(
      ReaderModeFontSizeParam param) async* {
    final settings = _repository.settings;
    final updateSettings = settings.copyWith(fontSizeParam: param);
    _repository.save(updateSettings);
    yield param;
  }
}
