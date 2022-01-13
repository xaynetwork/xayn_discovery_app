import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_outputs.dart';

@lazySingleton
class BookmarkErrorsEnumMapper {
  String mapEnumToString(BookmarkUseCaseErrorEnum errorEnum) {
    String msg;

    /// TODO replace with the POEditor string in order to have translation
    switch (errorEnum) {
      case BookmarkUseCaseErrorEnum.tryingToMoveNotExistingBookmark:
        msg = errorMsgTryingToMoveNotExistingBookmark;
        break;
      case BookmarkUseCaseErrorEnum.tryingToMoveBookmarkToNotExistingCollection:
        msg = errorMsgTryingToMoveBookmarkToNotExistingCollection;
        break;
      case BookmarkUseCaseErrorEnum.tryingToRemoveNotExistingBookmark:
        msg = errorMsgTryingToRemoveNotExistingBookmark;
        break;
      case BookmarkUseCaseErrorEnum
          .tryingToGetBookmarksForNotExistingCollection:
        msg = errorMsgTryingToGetBookmarksForNotExistingCollection;
        break;
    }
    return msg;
  }
}

const String errorMsgTryingToMoveNotExistingBookmark =
    'Trying to move a bookmark that doesn\t exist';
const String errorMsgTryingToMoveBookmarkToNotExistingCollection =
    'Trying to move a bookmark into a collection that doesn\t exist';
const String errorMsgTryingToRemoveNotExistingBookmark =
    'Trying to remove a bookmark that doesn\'t exist';
const String errorMsgTryingToGetBookmarksForNotExistingCollection =
    'Trying to get bookmarks for a collection that doesn\'t exist';
