import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

abstract class BookmarksRepository {
  void save(Bookmark bookmark);
  List<Bookmark> getAll();
  Bookmark? getById(UniqueId id);
  Bookmark? getByUrl(String url);
  List<Bookmark> getByCollectionId(UniqueId collectionId);
  void remove(Bookmark bookmark);
  void removeAllByCollectionId(UniqueId collectionId);
  Stream<RepositoryEvent> watch({UniqueId id});
}
