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
    final values = getAll();
    final idsToRemove =
        values.where((it) => it.collectionId == collectionId).map(
              (it) => it.id,
            );

    return removeAll(idsToRemove);
  }

  @override
  set bookmark(Bookmark bookmark) => entity = bookmark;
}
