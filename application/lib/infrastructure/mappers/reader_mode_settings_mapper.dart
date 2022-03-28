import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size_param.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_background_color_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_font_style_mapper.dart';

@singleton
class ReaderModeSettingsMapper extends BaseDbEntityMapper<ReaderModeSettings> {
  const ReaderModeSettingsMapper();

  @override
  ReaderModeSettings? fromMap(Map? map) {
    if (map == null) return null;

    final lightBackgroundColor =
        (map[ReaderModeSettingsFields.lightBackgroundColor] ??
            throwMapperException()) as int;
    final darkBackgroundColor =
        (map[ReaderModeSettingsFields.darkBackgroundColor] ??
            throwMapperException()) as int;

    final fontStyle = (map[ReaderModeSettingsFields.fontStyle] ??
        throwMapperException()) as int;

    final readerModeLightBackgroundColor =
        lightBackgroundColor.toReaderModeBackgroundLightColor;
    final readerModeDarkBackgroundColor =
        darkBackgroundColor.toReaderModeBackgroundDarkColor;
    final readerModeFontStyle = fontStyle.toReaderModeFontStyle;
    final fontSizeParam = _mapFontSizeParam(map);

    final backgroundColor = ReaderModeBackgroundColor(
      light: readerModeLightBackgroundColor,
      dark: readerModeDarkBackgroundColor,
    );

    return ReaderModeSettings.global(
      backgroundColor: backgroundColor,
      fontSizeParam: fontSizeParam,
      fontStyle: readerModeFontStyle,
    );
  }

  ReaderModeFontSizeParam _mapFontSizeParam(Map<dynamic, dynamic> map) {
    final fontSize = (map[ReaderModeSettingsFields.fontSize] ??
        throwMapperException()) as num;
    final fontHeight = map[ReaderModeSettingsFields.fontHeight] as double?;

    if (fontSize < ReaderModeFontSizeParams.min.size || fontHeight == null) {
      // this can happen if we migrate from the previous fontSize enum
      return ReaderModeFontSizeParams.defaultValue;
    }

    return ReaderModeFontSizeParam(
      size: fontSize.toDouble(),
      height: fontHeight,
    );
  }

  @override
  DbEntityMap toMap(ReaderModeSettings entity) => {
        ReaderModeSettingsFields.lightBackgroundColor:
            entity.backgroundColor.light.toInt,
        ReaderModeSettingsFields.darkBackgroundColor:
            entity.backgroundColor.dark.toInt,
        ReaderModeSettingsFields.fontSize: entity.fontSizeParam.size,
        ReaderModeSettingsFields.fontHeight: entity.fontSizeParam.height,
        ReaderModeSettingsFields.fontStyle: entity.fontStyle.toInt,
      };

  @override
  void throwMapperException([
    String exceptionText =
        'ReaderModeSettingsMapper: error occurred while mapping the object',
  ]) =>
      super.throwMapperException(exceptionText);
}

abstract class ReaderModeSettingsFields {
  ReaderModeSettingsFields._();

  static const int fontSize = 0;
  static const int fontStyle = 1;
  static const int lightBackgroundColor = 2;
  static const int darkBackgroundColor = 3;
  static const int fontHeight = 4;
}
