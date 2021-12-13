import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

import '../util/test_utils.dart';

import 'hive_app_settings_repository_test.mocks.dart';

@GenerateMocks([
  AppSettingsMapper,
])
void main() async {
  final box =
      await Hive.openBox<Record>(BoxNames.appSettings, bytes: Uint8List(0));

  late MockAppSettingsMapper mapper;
  late HiveAppSettingsRepository repository;

  setUp(() {
    initHiveAdapters();

    mapper = MockAppSettingsMapper();
    repository = HiveAppSettingsRepository(mapper);
  });

  group('HiveAppSettingsRepository', () {
    group('getSettings:', () {
      setUp(() async {
        when(mapper.toMap(any)).thenAnswer((_) => {
              0: true,
              1: 1,
              2: 1,
            });
        when(mapper.fromMap(null)).thenAnswer((_) => null);
        when(mapper.fromMap({
          0: true,
          1: 1,
          2: 1,
        })).thenAnswer((_) => AppSettings.initial());

        final appSettings = AppSettings.initial();
        repository.settings = appSettings;
      });

      tearDown(() async {
        await box.clear();
      });

      test('when there is no data persisted should return initial data',
          () async {
        await box.clear();

        final appSettings = repository.settings;

        expect(box.isEmpty, isTrue);
        expect(
          appSettings,
          AppSettings.initial(),
        );
      });

      test('when there is data it should return AppSettings', () async {
        final appSettings = repository.settings;

        expect(box.isNotEmpty, isTrue);
        expect(appSettings, isNotNull);
        expect(appSettings is AppSettings, isTrue);
        expect(appSettings.isOnboardingDone, isFalse);
        expect(
          appSettings.appTheme,
          equals(AppTheme.system),
        );
        expect(
          appSettings.discoveryFeedAxis,
          equals(DiscoveryFeedAxis.vertical),
        );
      });
    });

    group('save:', () {
      final appSettings = AppSettings.initial().copyWith(
        appTheme: AppTheme.dark,
        discoveryFeedAxis: DiscoveryFeedAxis.horizontal,
      );

      setUp(() async {
        final value = AppSettings.initial().copyWith(
          appTheme: AppTheme.dark,
          discoveryFeedAxis: DiscoveryFeedAxis.horizontal,
        );
        when(mapper.toMap(value)).thenAnswer((_) => {
              0: false,
              1: 2,
              2: 1,
            });
      });

      tearDown(() async {
        await box.clear();
      });

      test('given AppSettings should persist it in Hive box', () async {
        repository.settings = appSettings;

        expect(box.isNotEmpty, isTrue);
        expect(
            box.values.first.value,
            equals({
              0: false,
              1: 2,
              2: 1,
            }));
      });
    });
  });
}
