import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

void main() {
  const stringId = 'feed_settings_id';
  const uniqueId = UniqueId.fromTrustedString(stringId);
  test(
    'GIVEN feedSettings  WHEN created via initial constructor THEN verify params state and id is correct',
    () {
      final initial = FeedSettings.initial();

      expect(initial.id, equals(uniqueId));
      expect(initial.feedMarkets, isEmpty);
      expect(initial, isA<DbEntity>());
    },
  );
  test(
    'GIVEN FeedSettings THEN global id is correct',
    () {
      expect(FeedSettings.globalId, equals(uniqueId));
    },
  );
}
