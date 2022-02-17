import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

const int _system = 0;
const int _white = 1;
const int _black = 2;
const int _beige = 3;

@singleton
class IntToReaderModeBackgroundColorMapper
    implements Mapper<int?, ReaderModeBackgroundColor> {
  const IntToReaderModeBackgroundColorMapper();

  @override
  ReaderModeBackgroundColor map(int? input) {
    switch (input) {
      case _white:
        return ReaderModeBackgroundColor.white;
      case _beige:
        return ReaderModeBackgroundColor.beige;
      case _black:
        return ReaderModeBackgroundColor.black;
      case _system:
      default:
        return ReaderModeBackgroundColor.system;
    }
  }
}

@singleton
class ReaderModeBackgroundColorToIntMapper
    implements Mapper<ReaderModeBackgroundColor, int> {
  const ReaderModeBackgroundColorToIntMapper();

  @override
  int map(ReaderModeBackgroundColor input) {
    switch (input) {
      case ReaderModeBackgroundColor.white:
        return _white;
      case ReaderModeBackgroundColor.beige:
        return _beige;
      case ReaderModeBackgroundColor.black:
        return _black;
      case ReaderModeBackgroundColor.system:
      default:
        return _system;
    }
  }
}
