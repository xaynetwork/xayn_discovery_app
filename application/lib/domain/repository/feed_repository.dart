import 'package:xayn_discovery_app/domain/model/feed/feed.dart';

abstract class FeedRepository {
  void save(Feed feed);
  Feed get();
}
