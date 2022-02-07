import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

import 'bookmark_use_cases_errors.dart';

/// If the [UniqueId] is provided then return the list bookmarks by collection id
/// If the [UniqueId] is null then return the list of all bookmarks
@injectable
class GetAllBookmarksUseCase
    extends UseCase<GetAllBookmarksUseCaseIn, GetAllBookmarksUseCaseOut> {
  final BookmarksRepository _bookmarksRepository;
  final CollectionsRepository _collectionsRepository;

  GetAllBookmarksUseCase(
    this._bookmarksRepository,
    this._collectionsRepository,
  );
  @override
  Stream<GetAllBookmarksUseCaseOut> transaction(
      GetAllBookmarksUseCaseIn param) async* {
    late final List<Bookmark> bookmarks;
    final collectionId = param.collectionId;

    if (collectionId != null) {
      final collection = _collectionsRepository.getById(collectionId);

      if (collection == null) {
        throw BookmarkUseCaseError.tryingToGetBookmarksForNotExistingCollection;
      }
      bookmarks = _bookmarksRepository.getByCollectionId(collectionId);
    } else {
      bookmarks = _bookmarksRepository.getAll();
    }

    yield GetAllBookmarksUseCaseOut(bookmarks);
  }
}

class GetAllBookmarksUseCaseIn extends Equatable {
  final UniqueId? collectionId;

  const GetAllBookmarksUseCaseIn({this.collectionId});

  @override
  List<Object?> get props => [collectionId];
}

class GetAllBookmarksUseCaseOut extends Equatable {
  final List<Bookmark> bookmarks;

  const GetAllBookmarksUseCaseOut(this.bookmarks);

  @override
  List<Object> get props => [bookmarks];
}
