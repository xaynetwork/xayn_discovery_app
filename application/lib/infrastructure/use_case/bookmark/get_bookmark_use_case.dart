import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';

/// Pass DocumentId of a bookmark and expect a stream of this bookmark
@injectable
class GetBookmarkUseCase extends UseCase<String, Bookmark> {
  final BookmarksRepository _bookmarksRepository;

  GetBookmarkUseCase(this._bookmarksRepository);

  @override
  Stream<Bookmark> transaction(String param) async* {
    final bookmark = _bookmarksRepository.getByUrl(param);
    if (bookmark == null) {
      throw BookmarkUseCaseError.tryingToGetNotExistingBookmark;
    }
    yield bookmark;
  }
}
