import 'package:hive_crdt/hive_crdt.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_settings_repository.dart';

import '../../presentation/test_utils/utils.dart';
import 'hive_app_settings_repository_test.mocks.dart';

void main() {
  late MockFeedSettingsMapper mapper;
  late MockBox<Record> box;
  late HiveFeedSettingsRepository repository;

  setUp(() {
    mapper = MockFeedSettingsMapper();
    box = MockBox<Record>();
    repository = HiveFeedSettingsRepository.test(mapper, box);
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
      final feedSettings = repository.settings;

      expect(
        feedSettings,
        FeedSettings.initial(),
      );

      verify(box.toMap());
      verify(box.get('feed_settings_id'));
      verifyNoMoreInteractions(box);
    });

    test('when there is data it should return FeedSettings', () {
      final feedSettings = repository.settings;

      expect(feedSettings, isNotNull);
      expect(feedSettings.feedMarkets, isEmpty);

      verify(box.toMap());
      verify(box.get('feed_settings_id'));
      verifyNoMoreInteractions(box);
    });
  });

  group('save:', () {
    setUp(() {
      when(mapper.toMap(any)).thenAnswer((_) => {});
    });

    test('given FeedSettings should persist it in Hive box', () {
      repository.save(FeedSettings.initial());

      verify(box.toMap());
      verify(box.put('feed_settings_id', any));
      verifyNoMoreInteractions(box);
    });
  });
}
