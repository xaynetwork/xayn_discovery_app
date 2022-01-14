import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

import 'bookmark_use_cases_errors.dart';

typedef GetBookmarksHandler = List<Bookmark> Function(UniqueId? collectionId);

@injectable
class ListenBookmarksUseCase
    extends UseCase<ListenBookmarksUseCaseIn, ListenBookmarksUseCaseOut> {
  final BookmarksRepository _bookmarksRepository;
  final CollectionsRepository _collectionsRepository;

  ListenBookmarksUseCase(
    this._bookmarksRepository,
    this._collectionsRepository,
  );
  @override
  Stream<ListenBookmarksUseCaseOut> transaction(
      ListenBookmarksUseCaseIn param) async* {
    final collectionId = param.collectionId;
    late final GetBookmarksHandler getBookmarksHandler;

    if (collectionId != null) {
      final collection = _collectionsRepository.getById(collectionId);

      if (collection == null) {
        throw BookmarkUseCaseError.tryingToGetBookmarksForNotExistingCollection;
      }

      getBookmarksHandler =
          (UniqueId? id) => _bookmarksRepository.getByCollectionId(id!);
    } else {
      getBookmarksHandler = (_) => _bookmarksRepository.getAll();
    }

    yield* _bookmarksRepository.watch().map(
          (_) => ListenBookmarksUseCaseOut(
            getBookmarksHandler(param.collectionId),
          ),
        );
  }
}

class ListenBookmarksUseCaseIn extends Equatable {
  final UniqueId? collectionId;

  const ListenBookmarksUseCaseIn({this.collectionId});

  @override
  List<Object?> get props => [collectionId];
}

class ListenBookmarksUseCaseOut extends Equatable {
  final List<Bookmark> bookmarks;

  const ListenBookmarksUseCaseOut(this.bookmarks);

  @override
  List<Object?> get props => [bookmarks];
}
