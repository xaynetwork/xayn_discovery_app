import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_background_color_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_font_size_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_font_style_mapper.dart';

@singleton
class ReaderModeSettingsMapper extends BaseDbEntityMapper<ReaderModeSettings> {
  final IntToReaderModeBackgroundColorMapper _intToBackgroundColorMapper;
  final IntToReaderModeFontSizeMapper _intToFontSizeMapper;
  final IntToReaderModeFontStyleMapper _intToFontStyleMapper;
  final ReaderModeBackgroundColorToIntMapper _backgroundColorToIntMapper;
  final ReaderModeFontSizeToIntMapper _fontSizeToIntMapper;
  final ReaderModeFontStyleToIntMapper _fontStyleToIntMapper;

  const ReaderModeSettingsMapper(
    this._intToBackgroundColorMapper,
    this._intToFontSizeMapper,
    this._intToFontStyleMapper,
    this._backgroundColorToIntMapper,
    this._fontSizeToIntMapper,
    this._fontStyleToIntMapper,
  );

  @override
  ReaderModeSettings? fromMap(Map? map) {
    if (map == null) return null;

    final readerModeBackgroundColor = _intToBackgroundColorMapper
        .map(map[ReaderModeSettingsFields.readerModeBackgroundColor]);
    final readerModeFontSize = _intToFontSizeMapper
        .map(map[ReaderModeSettingsFields.readerModeFontSize]);
    final readerModeFontStyle = _intToFontStyleMapper
        .map(map[ReaderModeSettingsFields.readerModeFontStyle]);

    return ReaderModeSettings.global(
      backgroundColor: readerModeBackgroundColor,
      fontSize: readerModeFontSize,
      fontStyle: readerModeFontStyle,
    );
  }

  @override
  DbEntityMap toMap(ReaderModeSettings entity) => {
        ReaderModeSettingsFields.readerModeBackgroundColor:
            _backgroundColorToIntMapper.map(entity.readerModeBackgroundColor),
        ReaderModeSettingsFields.readerModeFontSize:
            _fontSizeToIntMapper.map(entity.readerModeFontSize),
        ReaderModeSettingsFields.readerModeFontStyle:
            _fontStyleToIntMapper.map(entity.readerModeFontStyle),
      };
}

abstract class ReaderModeSettingsFields {
  ReaderModeSettingsFields._();

  static const int readerModeBackgroundColor = 0;
  static const int readerModeFontSize = 1;
  static const int readerModeFontStyle = 2;
}
