import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

@lazySingleton
class BookmarkErrorsEnumMapper {
  String mapEnumToString(BookmarkUseCaseError errorEnum) {
    String msg;

    /// TODO replace with the POEditor string in order to have translation
    switch (errorEnum) {
      case BookmarkUseCaseError.tryingToMoveNotExistingBookmark:
        msg = Strings.errorMsgTryingToMoveNotExistingBookmark;
        break;
      case BookmarkUseCaseError.tryingToMoveBookmarkToNotExistingCollection:
        msg = Strings.errorMsgTryingToMoveBookmarkToNotExistingCollection;
        break;
      case BookmarkUseCaseError.tryingToRemoveNotExistingBookmark:
        msg = Strings.errorMsgTryingToRemoveNotExistingBookmark;
        break;
      case BookmarkUseCaseError.tryingToGetBookmarksForNotExistingCollection:
        msg = Strings.errorMsgTryingToGetBookmarksForNotExistingCollection;
        break;
    }
    return msg;
  }
}
