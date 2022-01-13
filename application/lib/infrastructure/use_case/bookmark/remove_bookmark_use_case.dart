import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';

import 'bookmark_use_cases_errors.dart';

@injectable
class RemoveBookmarkUseCase extends UseCase<UniqueId, Bookmark> {
  final BookmarksRepository _bookmarksRepository;
  RemoveBookmarkUseCase(this._bookmarksRepository);

  @override
  Stream<Bookmark> transaction(UniqueId param) async* {
    final bookmark = _bookmarksRepository.getById(param);
    if (bookmark == null) {
      throw BookmarkUseCaseError.tryingToRemoveNotExistingBookmark;
    }
    _bookmarksRepository.remove(bookmark);
    yield bookmark;
  }
}
