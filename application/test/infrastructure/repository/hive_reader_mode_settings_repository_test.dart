import 'package:hive_crdt/hive_crdt.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_reader_mode_settings_repository.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockReaderModeSettingsMapper mapper;
  late MockBox<Record> box;
  late HiveReaderModeSettingsRepository repository;

  setUp(() {
    mapper = MockReaderModeSettingsMapper();
    box = MockBox<Record>();
    repository = HiveReaderModeSettingsRepository.test(mapper, box);
  });

  setUp(() {
    when(box.get(any)).thenAnswer((_) => null);
    when(box.toMap()).thenAnswer((_) => {});
  });

  group('getSettings:', () {
    setUp(() {
      when(mapper.toMap(any)).thenAnswer((_) => {});
      when(mapper.fromMap(null)).thenAnswer((_) => null);
    });

    test('when there is no data persisted should return initial data', () {
      final settings = repository.settings;

      expect(
        settings,
        ReaderModeSettings.initial(),
      );

      verify(box.toMap());
      verify(box.get('reader_mode_settings_id'));
      verifyNoMoreInteractions(box);
    });

    test('when there is data it should return ReaderModeSettings', () {
      final settings = repository.settings;

      expect(settings, isNotNull);
      expect(settings.backgroundColor, ReaderModeBackgroundColor.initial());

      verify(box.toMap());
      verify(box.get('reader_mode_settings_id'));
      verifyNoMoreInteractions(box);
    });
  });

  group('save:', () {
    setUp(() {
      when(mapper.toMap(any)).thenAnswer((_) => {});
    });

    test('given ReaderModeSettings should persist it in Hive box', () {
      repository.save(ReaderModeSettings.initial());

      verify(box.toMap());
      verify(box.put('reader_mode_settings_id', any));
      verifyNoMoreInteractions(box);
    });
  });
}
