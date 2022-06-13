import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

import 'bookmark_use_cases_errors.dart';

@injectable
class MoveBookmarkUseCase extends UseCase<MoveBookmarkUseCaseIn, Bookmark> {
  final BookmarksRepository _bookmarksRepository;
  final CollectionsRepository _collectionsRepository;

  MoveBookmarkUseCase(
    this._bookmarksRepository,
    this._collectionsRepository,
  );

  @override
  Stream<Bookmark> transaction(MoveBookmarkUseCaseIn param) async* {
    final bookmark = _bookmarksRepository.getByUrl(param.bookmarkUrl);
    if (bookmark == null) {
      throw BookmarkUseCaseError.tryingToMoveNotExistingBookmark;
    }

    final collection = _collectionsRepository.getById(param.collectionId);

    if (collection == null) {
      throw BookmarkUseCaseError.tryingToMoveBookmarkToNotExistingCollection;
    }

    final updatedBookmark = bookmark.copyWith(collectionId: param.collectionId);
    _bookmarksRepository.save(updatedBookmark);
    yield updatedBookmark;
  }
}

class MoveBookmarkUseCaseIn extends Equatable {
  final String bookmarkUrl;
  final UniqueId collectionId;

  const MoveBookmarkUseCaseIn({
    required this.bookmarkUrl,
    required this.collectionId,
  });

  @override
  List<Object> get props => [bookmarkUrl, collectionId];
}
