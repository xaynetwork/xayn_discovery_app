import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class RemoveCollectionUseCase
    extends UseCase<RemoveCollectionUseCaseParam, None> {
  final CollectionsRepository _collectionsRepository;
  final BookmarksRepository _bookmarksRepository;

  RemoveCollectionUseCase(
    this._collectionsRepository,
    this._bookmarksRepository,
  );

  @override
  Stream<None> transaction(RemoveCollectionUseCaseParam param) async* {
    final collection =
        _collectionsRepository.getById(param.collectionIdToRemove);
    if (collection == null) {
      yield none;
      return;
    }

    /// Check if the bookmarks must be deleted or moved to a different collection
    if (param.collectionIdMoveBookmarksTo == null) {
      _bookmarksRepository.removeAllByCollectionId(param.collectionIdToRemove);
    } else {
      /// Move bookmarks to another collection
      final bookmarks =
          _bookmarksRepository.getByCollectionId(param.collectionIdToRemove);

      for (var bookmark in bookmarks) {
        _bookmarksRepository.bookmark = bookmark.copyWith(
          collectionId: param.collectionIdMoveBookmarksTo!,
        );
      }
    }

    _collectionsRepository.remove(collection);
    yield none;
  }
}

class RemoveCollectionUseCaseParam {
  final UniqueId collectionIdToRemove;
  final UniqueId? collectionIdMoveBookmarksTo;

  RemoveCollectionUseCaseParam({
    required this.collectionIdToRemove,
    this.collectionIdMoveBookmarksTo,
  });
}
