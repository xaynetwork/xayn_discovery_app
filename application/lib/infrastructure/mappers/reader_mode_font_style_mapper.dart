import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

const int _sans = 0;
const int _serif = 1;

extension ReaderModeFontStyleExtension on ReaderModeFontStyle {
  int get toInt {
    switch (this) {
      case ReaderModeFontStyle.serif:
        return _serif;
      case ReaderModeFontStyle.sans:
        return _sans;
      default:
        throw DbEntityMapperException(
            'ReaderModeFontStyle: error occurred while mapping the object to int ');
    }
  }
}

extension IntToReaderModeFontStyleExtension on int {
  ReaderModeFontStyle get toReaderModeFontStyle {
    switch (this) {
      case _serif:
        return ReaderModeFontStyle.serif;
      case _sans:
        return ReaderModeFontStyle.sans;
      default:
        throw DbEntityMapperException(
            'ReaderModeFontStyle: error occurred while mapping int to the object');
    }
  }
}
