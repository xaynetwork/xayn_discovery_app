import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_exception.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

typedef GetBookmarksHandler = List<Bookmark> Function(UniqueId? collectionId);

@injectable
class ListenBookmarksUseCase
    extends UseCase<ListBookmarksUseCaseIn, ListBookmarksUseCaseOut> {
  final BookmarksRepository _bookmarksRepository;
  final CollectionsRepository _collectionsRepository;

  ListenBookmarksUseCase(
    this._bookmarksRepository,
    this._collectionsRepository,
  );
  @override
  Stream<ListBookmarksUseCaseOut> transaction(
      ListBookmarksUseCaseIn param) async* {
    final collectionId = param.collectionId;
    late final GetBookmarksHandler getBookmarksHandler;

    if (collectionId != null) {
      final collection = _collectionsRepository.getById(collectionId);

      if (collection == null) {
        logger.e(errorMessageGettingBookmarksOfNotExistingCollection);
        throw BookmarkUseCaseException(
          errorMessageGettingBookmarksOfNotExistingCollection,
        );
      }

      getBookmarksHandler =
          (UniqueId? id) => _bookmarksRepository.getByCollectionId(id!);
    } else {
      getBookmarksHandler = (_) => _bookmarksRepository.getAll();
    }

    yield* _bookmarksRepository.watch().map(
          (_) => ListBookmarksUseCaseOut(
            getBookmarksHandler(param.collectionId),
          ),
        );
  }
}

class ListBookmarksUseCaseIn extends Equatable {
  final UniqueId? collectionId;

  const ListBookmarksUseCaseIn({this.collectionId});

  @override
  List<Object?> get props => [collectionId];
}

class ListBookmarksUseCaseOut extends Equatable {
  final List<Bookmark> bookmarks;

  const ListBookmarksUseCaseOut(this.bookmarks);

  @override
  List<Object?> get props => [bookmarks];
}
