import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

import 'collection_exception.dart';

@injectable
class RemoveCollectionUseCase
    extends UseCase<RemoveCollectionUseCaseParam, Collection?> {
  final CollectionsRepository _collectionsRepository;
  final BookmarksRepository _bookmarksRepository;

  RemoveCollectionUseCase(
    this._collectionsRepository,
    this._bookmarksRepository,
  );

  @override
  Stream<Collection?> transaction(RemoveCollectionUseCaseParam param) async* {
    /// Check if we're trying to delete the default collection
    if (param.collectionIdToRemove == Collection.readLaterId) {
      logger.e(errorMessageRemovingExistingDefaultCollection);
      throw CollectionUseCaseException(
        errorMessageRemovingExistingDefaultCollection,
      );
    }

    final collection =
        _collectionsRepository.getById(param.collectionIdToRemove);

    if (collection == null) {
      logger.e(errorMessageRemovingNotExistingCollection);
      throw CollectionUseCaseException(
        errorMessageRemovingNotExistingCollection,
      );
    }

    /// Check if the bookmarks must be deleted or moved to a different collection
    if (param.collectionIdMoveBookmarksTo == null) {
      _bookmarksRepository.removeAllByCollectionId(param.collectionIdToRemove);
    } else {
      /// Move bookmarks to another collection
      final bookmarks =
          _bookmarksRepository.getByCollectionId(param.collectionIdToRemove);

      for (var bookmark in bookmarks) {
        _bookmarksRepository.save(
          bookmark.copyWith(
            collectionId: param.collectionIdMoveBookmarksTo!,
          ),
        );
      }
    }

    _collectionsRepository.remove(collection);
    yield collection;
  }
}

class RemoveCollectionUseCaseParam extends Equatable {
  final UniqueId collectionIdToRemove;
  final UniqueId? collectionIdMoveBookmarksTo;

  const RemoveCollectionUseCaseParam({
    required this.collectionIdToRemove,
    this.collectionIdMoveBookmarksTo,
  });

  @override
  List<Object?> get props =>
      [collectionIdToRemove, collectionIdMoveBookmarksTo];
}
