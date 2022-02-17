import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

const int _small = 0;
const int _medium = 1;
const int _large = 2;

@singleton
class IntToReaderModeFontSizeMapper
    implements Mapper<int?, ReaderModeFontSize> {
  const IntToReaderModeFontSizeMapper();

  @override
  ReaderModeFontSize map(int? input) {
    switch (input) {
      case _small:
        return ReaderModeFontSize.small;
      case _large:
        return ReaderModeFontSize.large;
      case _medium:
      default:
        return ReaderModeFontSize.medium;
    }
  }
}

@singleton
class ReaderModeFontSizeToIntMapper implements Mapper<ReaderModeFontSize, int> {
  const ReaderModeFontSizeToIntMapper();

  @override
  int map(ReaderModeFontSize input) {
    switch (input) {
      case ReaderModeFontSize.small:
        return _small;
      case ReaderModeFontSize.large:
        return _large;
      case ReaderModeFontSize.medium:
      default:
        return _medium;
    }
  }
}
