import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

const int _dark = 0;
const int _white = 1;
const int _trueBlack = 2;
const int _beige = 3;

extension ReaderModeBackgroundLightColorExtension
    on ReaderModeBackgroundLightColor {
  int get toInt {
    switch (this) {
      case ReaderModeBackgroundLightColor.beige:
        return _beige;
      case ReaderModeBackgroundLightColor.white:
        return _white;
      default:
        throw DbEntityMapperException(
            'ReaderModeBackgroundLightColor: error occurred while mapping the object to int');
    }
  }
}

extension ReaderModeBackgroundDarkColorExtension
    on ReaderModeBackgroundDarkColor {
  int get toInt {
    switch (this) {
      case ReaderModeBackgroundDarkColor.trueBlack:
        return _trueBlack;
      case ReaderModeBackgroundDarkColor.dark:
        return _dark;
      default:
        throw DbEntityMapperException(
            'ReaderModeBackgroundDarkColor: error occurred while mapping the object to int');
    }
  }
}

extension IntToReaderModeBackgroundColorExtension on int {
  ReaderModeBackgroundDarkColor get toReaderModeBackgroundDarkColor {
    switch (this) {
      case _trueBlack:
        return ReaderModeBackgroundDarkColor.trueBlack;
      case _dark:
        return ReaderModeBackgroundDarkColor.dark;
      default:
        throw DbEntityMapperException(
            'ReaderModeBackgroundDarkColor: error occurred while mapping int to the object');
    }
  }

  ReaderModeBackgroundLightColor get toReaderModeBackgroundLightColor {
    switch (this) {
      case _beige:
        return ReaderModeBackgroundLightColor.beige;
      case _white:
        return ReaderModeBackgroundLightColor.white;
      default:
        throw DbEntityMapperException(
            'ReaderModeBackgroundLightColor: error occurred while mapping int to the object');
    }
  }
}
