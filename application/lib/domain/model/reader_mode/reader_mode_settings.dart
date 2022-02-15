import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'reader_mode_settings.freezed.dart';

@freezed
class ReaderModeSettings extends DbEntity with _$ReaderModeSettings {
  factory ReaderModeSettings._({
    required ReaderModeBackgroundColor readerModeBackgroundColor,
    required ReaderModeFontSize readerModeFontSize,
    required ReaderModeFontStyle readerModeFontStyle,
    required UniqueId id,
  }) = _ReaderModeSettings;

  factory ReaderModeSettings.global({
    required ReaderModeBackgroundColor readerModeBackgroundColor,
    required ReaderModeFontSize readerModeFontSize,
    required ReaderModeFontStyle readerModeFontStyle,
  }) =>
      ReaderModeSettings._(
        id: ReaderModeSettings.globalId,
        readerModeBackgroundColor: readerModeBackgroundColor,
        readerModeFontSize: readerModeFontSize,
        readerModeFontStyle: readerModeFontStyle,
      );

  factory ReaderModeSettings.initial() => ReaderModeSettings._(
        id: ReaderModeSettings.globalId,
        readerModeBackgroundColor: ReaderModeBackgroundColor.system,
        readerModeFontSize: ReaderModeFontSize.medium,
        readerModeFontStyle: ReaderModeFontStyle.serif,
      );

  static UniqueId globalId =
      const UniqueId.fromTrustedString('reader_mode_settings_id');
}
