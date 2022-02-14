import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_state.dart';

@singleton
class EditReaderModeSettingsManager extends Cubit<EditReaderModeSettingsState>
    with UseCaseBlocHelper<EditReaderModeSettingsState> {
  EditReaderModeSettingsManager(
    ReaderModeSettingsRepository readerModeSettingsRepository,
  ) : super(EditReaderModeSettingsState(
          readerModeFontStyle:
              readerModeSettingsRepository.settings.readerModeFontStyle,
          readerModeFontSize:
              readerModeSettingsRepository.settings.readerModeFontSize,
          readerModeBackgroundColor:
              readerModeSettingsRepository.settings.readerModeBackgroundColor,
        ));

  void onBackgroundColorPressed(ReaderModeBackgroundColor color) {}

  void onFontSizePressed(ReaderModeFontSize fontSize) {}

  void onFontStylePressed(ReaderModeFontStyle fontStyle) {}
}
