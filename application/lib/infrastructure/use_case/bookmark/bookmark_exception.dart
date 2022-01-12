const String errorMessageMovingNotExistingBookmark =
    'Trying to move a bookmark that doesn\'t exist';
const String errorMessageMovingBookmarkToNotExistingCollection =
    'Trying to move a bookmark to a collection that doesn\'t exist';
const String errorMessageGettingBookmarksOfNotExistingCollection =
    'Trying to get bookmarks of a collection that doesn\'t exist';
const String errorMessageRemovingNotExistingBookmark =
    'Trying to remove a bookmark that doesn\'t exist';
const String errorMessageListeningNullOrWrongBookmark =
    'Listening a null or wrong bookmark';

class BookmarkUseCaseException implements Exception {
  final String msg;

  BookmarkUseCaseException(this.msg);

  @override
  String toString() => msg;
}
