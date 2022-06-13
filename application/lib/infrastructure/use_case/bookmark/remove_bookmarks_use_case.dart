import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';

@injectable
class RemoveBookmarksUseCase
    extends UseCase<RemoveBookmarksUseCaseIn, RemoveBookmarksUseCaseOut> {
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  RemoveBookmarksUseCase(
    this._removeBookmarkUseCase,
  );

  @override
  Stream<RemoveBookmarksUseCaseOut> transaction(
      RemoveBookmarksUseCaseIn param) async* {
    List<Bookmark> removedBookmarks = [];
    for (var bookmarkUrl in param.bookmarksUrls) {
      final removedBookmark = await _removeBookmarkUseCase.singleOutput(
        bookmarkUrl,
      );
      removedBookmarks.add(removedBookmark);
    }
    yield RemoveBookmarksUseCaseOut(removedBookmarks: removedBookmarks);
  }
}

class RemoveBookmarksUseCaseIn extends Equatable {
  final List<String> bookmarksUrls;

  const RemoveBookmarksUseCaseIn({required this.bookmarksUrls});

  @override
  List<Object> get props => [bookmarksUrls];
}

class RemoveBookmarksUseCaseOut extends Equatable {
  final List<Bookmark> removedBookmarks;

  const RemoveBookmarksUseCaseOut({
    required this.removedBookmarks,
  });

  @override
  List<Object> get props => [removedBookmarks];
}
