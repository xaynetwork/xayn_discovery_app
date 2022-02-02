import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';

@injectable
class RemoveBookmarskUseCase
    extends UseCase<RemoveBookmarskUseCaseIn, RemoveBookmarskUseCaseOut> {
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  RemoveBookmarskUseCase(
    this._removeBookmarkUseCase,
  );

  @override
  Stream<RemoveBookmarskUseCaseOut> transaction(
      RemoveBookmarskUseCaseIn param) async* {
    List<Bookmark> removedBookmarks = [];
    for (var bookmarkId in param.bookmarksIds) {
      final removedBookmark = await _removeBookmarkUseCase.singleOutput(
        bookmarkId,
      );
      removedBookmarks.add(removedBookmark);
    }
    yield RemoveBookmarskUseCaseOut(removedBookmarks: removedBookmarks);
  }
}

class RemoveBookmarskUseCaseIn extends Equatable {
  final List<UniqueId> bookmarksIds;

  const RemoveBookmarskUseCaseIn({required this.bookmarksIds});

  @override
  List<Object?> get props => [bookmarksIds];
}

class RemoveBookmarskUseCaseOut extends Equatable {
  final List<Bookmark> removedBookmarks;

  const RemoveBookmarskUseCaseOut({
    required this.removedBookmarks,
  });

  @override
  List<Object?> get props => [removedBookmarks];
}
