import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_exception.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

@injectable
class MoveBookmarkUseCase extends UseCase<MoveBookmarkUseCaseParam, None> {
  final BookmarksRepository _bookmarksRepository;
  final CollectionsRepository _collectionsRepository;

  MoveBookmarkUseCase(
    this._bookmarksRepository,
    this._collectionsRepository,
  );

  @override
  Stream<None> transaction(MoveBookmarkUseCaseParam param) async* {
    final bookmark = _bookmarksRepository.getById(param.bookmarkId);
    if (bookmark == null) {
      logger.e(errorMessageMovingNotExistingBookmark);
      throw BookmarkUseCaseException(errorMessageMovingNotExistingBookmark);
    }

    final collection = _collectionsRepository.getById(param.collectionId);

    if (collection == null) {
      logger.e(errorMessageMovingBookmarkToNotExistingCollection);
      throw BookmarkUseCaseException(
        errorMessageMovingBookmarkToNotExistingCollection,
      );
    }

    final updatedBookmark = bookmark.copyWith(collectionId: param.collectionId);
    _bookmarksRepository.bookmark = updatedBookmark;
    yield none;
  }
}

class MoveBookmarkUseCaseParam {
  final UniqueId bookmarkId;
  final UniqueId collectionId;

  MoveBookmarkUseCaseParam({
    required this.bookmarkId,
    required this.collectionId,
  });
}
