import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';

import 'bookmark_use_cases_outputs.dart';

@injectable
class RemoveBookmarkUseCase
    extends UseCase<UniqueId, BookmarkUseCaseGenericOut> {
  final BookmarksRepository _bookmarksRepository;
  RemoveBookmarkUseCase(this._bookmarksRepository);

  @override
  Stream<BookmarkUseCaseGenericOut> transaction(UniqueId param) async* {
    final bookmark = _bookmarksRepository.getById(param);
    if (bookmark == null) {
      yield const BookmarkUseCaseGenericOut.failure(
          BookmarkUseCaseErrorEnum.tryingToRemoveNotExistingBookmark);
      return;
    }
    _bookmarksRepository.remove(bookmark);
    yield BookmarkUseCaseGenericOut.success(bookmark);
  }
}
