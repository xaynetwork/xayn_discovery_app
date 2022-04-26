import 'package:hive_crdt/hive_crdt.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_app_settings_repository.dart';

import '../../test_utils/utils.dart';

void main() async {
  late MockAppSettingsMapper mapper;
  late MockBox<Record> box;
  late HiveAppSettingsRepository repository;

  setUp(() {
    mapper = MockAppSettingsMapper();
    box = MockBox<Record>();
    repository = HiveAppSettingsRepository.test(mapper, box);
  });

  group('HiveAppSettingsRepository', () {
    setUp(() async {
      when(box.get(any)).thenAnswer((_) => null);
      when(box.toMap()).thenAnswer((_) => {});
    });

    group('getSettings:', () {
      setUp(() async {
        when(mapper.toMap(any)).thenAnswer((_) => {});
        when(mapper.fromMap(null)).thenAnswer((_) => null);
      });

      test('when there is no data persisted should return initial data',
          () async {
        final appSettings = repository.settings;

        expect(
          appSettings,
          AppSettings.initial(),
        );

        verify(box.toMap());
        verify(box.get('app_settings_id'));
        verifyNoMoreInteractions(box);
      });

      test('when there is data it should return AppSettings', () async {
        final appSettings = repository.settings;

        expect(appSettings, isNotNull);
        expect(
          appSettings.appTheme,
          equals(AppTheme.system),
        );

        verify(box.toMap());
        verify(box.get('app_settings_id'));
        verifyNoMoreInteractions(box);
      });
    });

    group('save:', () {
      setUp(() async {
        when(mapper.toMap(any)).thenAnswer((_) => {});
      });

      test('given AppSettings should persist it in Hive box', () async {
        repository.save(
          AppSettings.initial(),
        );

        verify(box.toMap());
        verify(box.put('app_settings_id', any));
        verifyNoMoreInteractions(box);
      });
    });
  });
}
