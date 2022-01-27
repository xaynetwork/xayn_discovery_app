import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/bookmark_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

import 'hive_repository.dart';

@Singleton(as: BookmarksRepository)
class HiveBookmarksRepository extends HiveRepository<Bookmark>
    implements BookmarksRepository {
  final BookmarkMapper _mapper;

  HiveBookmarksRepository(this._mapper);

  @override
  Box<Record> get box => Hive.box<Record>(BoxNames.bookmarks);

  @override
  BaseDbEntityMapper<Bookmark> get mapper => _mapper;

  @override
  void removeAllByCollectionId(UniqueId collectionId) {
    final idsToRemove = getByCollectionId(collectionId).map((it) => it.id);

    removeAll(idsToRemove);
  }

  @override
  List<Bookmark> getByCollectionId(UniqueId collectionId) {
    final bookmarks = getAll()
        .where((element) => element.collectionId == collectionId)
        .toList(growable: false);
    bookmarks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return bookmarks;
  }
}
