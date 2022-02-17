import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

const int _sans = 0;
const int _serif = 1;

@singleton
class IntToReaderModeFontStyleMapper
    implements Mapper<int?, ReaderModeFontStyle> {
  const IntToReaderModeFontStyleMapper();

  @override
  ReaderModeFontStyle map(int? input) {
    switch (input) {
      case _serif:
        return ReaderModeFontStyle.serif;
      case _sans:
      default:
        return ReaderModeFontStyle.sans;
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
      case ReaderModeFontStyle.serif:
        return _serif;
      case ReaderModeFontStyle.sans:
      default:
        return _sans;
    }
  }
}
