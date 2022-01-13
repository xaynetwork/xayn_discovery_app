import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';

part 'bookmark_use_cases_outputs.freezed.dart';

enum BookmarkUseCaseErrorEnum {
  tryingToMoveNotExistingBookmark,
  tryingToMoveBookmarkToNotExistingCollection,
  tryingToRemoveNotExistingBookmark,
  tryingToGetBookmarksForNotExistingCollection,
}

@freezed
class BookmarkUseCaseGenericOut with _$BookmarkUseCaseGenericOut {
  const factory BookmarkUseCaseGenericOut.success(Bookmark bookmark) =
      _BookmarkUseCaseGenericOutSuccess;
  const factory BookmarkUseCaseGenericOut.failure(
    BookmarkUseCaseErrorEnum error,
  ) = _BookmarkUseCaseGenericOutFailure;
}

@freezed
class BookmarkUseCaseListOut with _$BookmarkUseCaseListOut {
  const factory BookmarkUseCaseListOut.success(List<Bookmark> bookmarks) =
      _BookmarkUseCaseListOutSuccess;
  const factory BookmarkUseCaseListOut.failure(
    BookmarkUseCaseErrorEnum error,
  ) = _BookmarkUseCaseListOutFailure;
}
