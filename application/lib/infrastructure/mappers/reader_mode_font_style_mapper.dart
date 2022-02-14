import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

const int _serif = 0;
const int _sansSerif = 1;

@singleton
class IntToReaderModeFontStyleMapper
    implements Mapper<int?, ReaderModeFontStyle> {
  const IntToReaderModeFontStyleMapper();

  @override
  ReaderModeFontStyle map(int? input) {
    switch (input) {
      case _sansSerif:
        return ReaderModeFontStyle.sansSerif;
      case _serif:
      default:
        return ReaderModeFontStyle.serif;
    }
  }
}

@singleton
class ReaderModeFontStyleToIntMapper
    implements Mapper<ReaderModeFontStyle, int> {
  const ReaderModeFontStyleToIntMapper();

  @override
  int map(ReaderModeFontStyle input) {
    switch (input) {
      case ReaderModeFontStyle.sansSerif:
        return _sansSerif;
      case ReaderModeFontStyle.serif:
      default:
        return _serif;
    }
  }
}
