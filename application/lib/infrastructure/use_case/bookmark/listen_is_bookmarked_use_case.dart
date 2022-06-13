import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';

/// Pass DocumentId of a bookmark and listen to repository changes then expect a stream if it was bookmarked or not
@injectable
class ListenIsBookmarkedUseCase
    extends UseCase<ListenIsBookmarkUseCaseIn, BookmarkStatus> {
  final BookmarksRepository _bookmarksRepository;

  ListenIsBookmarkedUseCase(this._bookmarksRepository);

  @override
  Stream<BookmarkStatus> transaction(ListenIsBookmarkUseCaseIn param) async* {
    // initial event
    yield _bookmarksRepository.getByUrl(param.url) != null
        ? BookmarkStatus.bookmarked
        : BookmarkStatus.notBookmarked;

    // changes & deletes are from now on watched
    yield* _bookmarksRepository
        .watch()
        .map((_) => _bookmarksRepository.getByUrl(param.url))
        .distinct()
        .map((event) => event != null
            ? BookmarkStatus.bookmarked
            : BookmarkStatus.notBookmarked);
  }
}

class ListenIsBookmarkUseCaseIn {
  final UniqueId id;
  final String url;

  ListenIsBookmarkUseCaseIn({
    required this.id,
    required this.url,
  });
}
