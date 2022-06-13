import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';

@injectable
class MoveBookmarksUseCase
    extends UseCase<MoveBookmarksUseCaseIn, MoveBookmarksUseCaseOut> {
  final MoveBookmarkUseCase _moveBookmarkUseCase;

  MoveBookmarksUseCase(
    this._moveBookmarkUseCase,
  );

  @override
  Stream<MoveBookmarksUseCaseOut> transaction(
    MoveBookmarksUseCaseIn param,
  ) async* {
    final List<Bookmark> updatedBookmarks = [];
    for (final bookmarkId in param.bookmarkUrls) {
      final updatedBookmark = await _moveBookmarkUseCase.singleOutput(
        MoveBookmarkUseCaseIn(
          bookmarkUrl: bookmarkId,
          collectionId: param.collectionId,
        ),
      );
      updatedBookmarks.add(updatedBookmark);
    }
    yield MoveBookmarksUseCaseOut(updatedBookmarks: updatedBookmarks);
  }
}

class MoveBookmarksUseCaseIn extends Equatable {
  final List<String> bookmarkUrls;
  final UniqueId collectionId;

  const MoveBookmarksUseCaseIn({
    required this.bookmarkUrls,
    required this.collectionId,
  });

  @override
  List<Object> get props => [bookmarkUrls, collectionId];
}

class MoveBookmarksUseCaseOut extends Equatable {
  final List<Bookmark> updatedBookmarks;

  const MoveBookmarksUseCaseOut({
    required this.updatedBookmarks,
  });

  @override
  List<Object> get props => [updatedBookmarks];
}
