import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/document_repository.dart';

import 'bookmark_use_cases_errors.dart';

@injectable
class RemoveBookmarkUseCase extends UseCase<UniqueId, Bookmark> {
  final BookmarksRepository _bookmarksRepository;
  final DocumentRepository _documentRepository;
  RemoveBookmarkUseCase(this._bookmarksRepository, this._documentRepository);

  @override
  Stream<Bookmark> transaction(UniqueId param) async* {
    final bookmark = _bookmarksRepository.getById(param);
    if (bookmark == null) {
      throw BookmarkUseCaseError.tryingToRemoveNotExistingBookmark;
    }
    _bookmarksRepository.remove(bookmark);
    final document = _documentRepository.getById(bookmark.id);
    if (document != null) {
      _documentRepository.remove(document);
    }
    yield bookmark;
  }
}
