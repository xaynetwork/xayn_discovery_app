import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';

part 'edit_reader_mode_settings_state.freezed.dart';

/// The state of the [EditReaderModeSettingsManager].
@freezed
class EditReaderModeSettingsState with _$EditReaderModeSettingsState {
  const factory EditReaderModeSettingsState({
    required ReaderModeBackgroundColor readerModeBackgroundColor,
    required ReaderModeFontSize readerModeFontSize,
    required ReaderModeFontStyle readerModeFontStyle,
  }) = _EditReaderModeSettingsState;
}
