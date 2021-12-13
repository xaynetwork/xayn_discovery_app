import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

abstract class BookmarksRepository {
  set bookmark(Bookmark bookmark);
  List<Bookmark> getAll();
  void remove(Bookmark bookmark);
  void removeAllByCollectionId(UniqueId collectionId);
  Stream<RepositoryEvent> watch({UniqueId id});
}
