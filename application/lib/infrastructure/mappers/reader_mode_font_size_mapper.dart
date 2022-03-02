import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

const int _small = 0;
const int _medium = 1;
const int _large = 2;

extension ReaderModeFontSizeExtension on ReaderModeFontSize {
  int get toInt {
    switch (this) {
      case ReaderModeFontSize.small:
        return _small;
      case ReaderModeFontSize.large:
        return _large;
      case ReaderModeFontSize.medium:
        return _medium;
      default:
        throw DbEntityMapperException(
            'ReaderModeFontSize: error occurred while mapping the object to int');
    }
  }
}

extension IntToReaderModeFontSizeExtension on int {
  ReaderModeFontSize get toReaderModeFontSize {
    switch (this) {
      case _small:
        return ReaderModeFontSize.small;
      case _large:
        return ReaderModeFontSize.large;
      case _medium:
        return ReaderModeFontSize.medium;
      default:
        throw DbEntityMapperException(
            'ReaderModeFontSize: error occurred while mapping int to the object');
    }
  }
}
