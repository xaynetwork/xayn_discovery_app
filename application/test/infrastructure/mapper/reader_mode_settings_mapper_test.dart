import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_background_color_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_font_size_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_font_style_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_settings_mapper.dart';

import 'reader_mode_settings_mapper_test.mocks.dart';

@GenerateMocks([
  IntToReaderModeBackgroundColorMapper,
  IntToReaderModeFontSizeMapper,
  IntToReaderModeFontStyleMapper,
  ReaderModeBackgroundColorToIntMapper,
  ReaderModeFontSizeToIntMapper,
  ReaderModeFontStyleToIntMapper,
])
void main() {
  late ReaderModeSettingsMapper mapper;

  late MockIntToReaderModeBackgroundColorMapper
      mockIntToReaderModeBackgroundColorMapper;
  late MockIntToReaderModeFontSizeMapper mockIntToReaderModeFontSizeMapper;
  late MockIntToReaderModeFontStyleMapper mockIntToReaderModeFontStyleMapper;
  late MockReaderModeBackgroundColorToIntMapper
      mockReaderModeBackgroundColorToIntMapper;
  late MockReaderModeFontSizeToIntMapper mockReaderModeFontSizeToIntMapper;
  late MockReaderModeFontStyleToIntMapper mockReaderModeFontStyleToIntMapper;

  setUp(() async {
    mockIntToReaderModeBackgroundColorMapper =
        MockIntToReaderModeBackgroundColorMapper();
    mockIntToReaderModeFontSizeMapper = MockIntToReaderModeFontSizeMapper();
    mockIntToReaderModeFontStyleMapper = MockIntToReaderModeFontStyleMapper();
    mockReaderModeBackgroundColorToIntMapper =
        MockReaderModeBackgroundColorToIntMapper();
    mockReaderModeFontSizeToIntMapper = MockReaderModeFontSizeToIntMapper();
    mockReaderModeFontStyleToIntMapper = MockReaderModeFontStyleToIntMapper();

    mapper = ReaderModeSettingsMapper(
      mockIntToReaderModeBackgroundColorMapper,
      mockIntToReaderModeFontSizeMapper,
      mockIntToReaderModeFontStyleMapper,
      mockReaderModeBackgroundColorToIntMapper,
      mockReaderModeFontSizeToIntMapper,
      mockReaderModeFontStyleToIntMapper,
    );
  });

  group('ReaderModeSettingsMapper tests: ', () {
    test('fromMap', () {
      when(mockIntToReaderModeBackgroundColorMapper.map(1)).thenAnswer(
        (_) => ReaderModeBackgroundColor.beige,
      );
      when(mockIntToReaderModeFontSizeMapper.map(2)).thenAnswer(
        (_) => ReaderModeFontSize.large,
      );
      when(mockIntToReaderModeFontStyleMapper.map(1)).thenAnswer(
        (_) => ReaderModeFontStyle.serif,
      );
      final map = {
        0: 1,
        1: 2,
        2: 1,
      };
      final settings = mapper.fromMap(map);
      expect(
        settings,
        ReaderModeSettings.global(
          backgroundColor: ReaderModeBackgroundColor.beige,
          fontSize: ReaderModeFontSize.large,
          fontStyle: ReaderModeFontStyle.serif,
        ),
      );
    });

    test('toMap', () {
      when(mockReaderModeBackgroundColorToIntMapper
              .map(ReaderModeBackgroundColor.beige))
          .thenAnswer(
        (_) => 1,
      );
      when(mockReaderModeFontSizeToIntMapper.map(ReaderModeFontSize.large))
          .thenAnswer(
        (_) => 2,
      );
      when(mockReaderModeFontStyleToIntMapper.map(ReaderModeFontStyle.serif))
          .thenAnswer(
        (_) => 1,
      );
      final settings = ReaderModeSettings.global(
        backgroundColor: ReaderModeBackgroundColor.beige,
        fontSize: ReaderModeFontSize.large,
        fontStyle: ReaderModeFontStyle.serif,
      );
      final map = mapper.toMap(settings);
      final expectedMap = {
        0: 1,
        1: 2,
        2: 1,
      };
      expect(map, expectedMap);
    });
  });
}
