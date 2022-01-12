import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';

part 'bookmarks_screen_state.freezed.dart';

@freezed
class BookmarksScreenState with _$BookmarksScreenState {
  const BookmarksScreenState._();

  const factory BookmarksScreenState({
    /// The list of bookmarks
    required List<Bookmark> bookmarks,

    /// Timestamp of update time (for making sure that state is emitted)
    required DateTime? timestamp,

    /// Error message
    String? errorMsg,
  }) = _BookmarksScreenState;

  factory BookmarksScreenState.initial({DateTime? timeStamp}) =>
      BookmarksScreenState(
        bookmarks: const [],
        timestamp: timeStamp,
      );

  factory BookmarksScreenState.populated(
    List<Bookmark> bookmarks,
    DateTime timestamp,
  ) =>
      BookmarksScreenState(
        bookmarks: bookmarks,
        timestamp: timestamp,
      );
}
