import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size_param.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'reader_mode_settings.freezed.dart';

@freezed
class ReaderModeSettings extends DbEntity with _$ReaderModeSettings {
  factory ReaderModeSettings._({
    required ReaderModeBackgroundColor backgroundColor,
    required ReaderModeFontSizeParam fontSizeParam,
    required ReaderModeFontStyle fontStyle,
    required UniqueId id,
  }) = _ReaderModeSettings;

  factory ReaderModeSettings.global({
    required ReaderModeBackgroundColor backgroundColor,
    required ReaderModeFontSizeParam fontSizeParam,
    required ReaderModeFontStyle fontStyle,
  }) =>
      ReaderModeSettings._(
        id: ReaderModeSettings.globalId,
        backgroundColor: backgroundColor,
        fontSizeParam: fontSizeParam,
        fontStyle: fontStyle,
      );

  factory ReaderModeSettings.initial() => ReaderModeSettings._(
        id: ReaderModeSettings.globalId,
        backgroundColor: ReaderModeBackgroundColor.initial(),
        fontSizeParam: ReaderModeFontSizeParams.defaultValue,
        fontStyle: ReaderModeFontStyle.sans,
      );

  static UniqueId globalId =
      const UniqueId.fromTrustedString('reader_mode_settings_id');
}
