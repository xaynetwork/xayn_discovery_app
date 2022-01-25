import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

@lazySingleton
class BookmarkErrorsEnumMapper {
  String mapEnumToString(BookmarkUseCaseError errorEnum) {
    String msg;

    switch (errorEnum) {
      case BookmarkUseCaseError.tryingToMoveNotExistingBookmark:
        msg = R.strings.errorMsgBookmarkDoesntExist;
        break;
      case BookmarkUseCaseError.tryingToMoveBookmarkToNotExistingCollection:
        msg = R.strings.errorMsgCollectionDoesntExist;
        break;
      case BookmarkUseCaseError.tryingToRemoveNotExistingBookmark:
        msg = R.strings.errorMsgBookmarkDoesntExist;
        break;
      case BookmarkUseCaseError.tryingToGetBookmarksForNotExistingCollection:
        msg = R.strings.errorMsgCollectionDoesntExist;
        break;
      case BookmarkUseCaseError.tryingToGetNotExistingBookmark:
        msg = R.strings.errorMsgBookmarkDoesntExist;
        break;
    }
    return msg;
  }
}
