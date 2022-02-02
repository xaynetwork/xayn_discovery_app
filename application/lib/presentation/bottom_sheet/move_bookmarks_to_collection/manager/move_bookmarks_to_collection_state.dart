import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';

part 'move_bookmarks_to_collection_state.freezed.dart';

/// Represents the state of the [MoveBookmarkToCollectionManager].
@freezed
class MoveBookmarksToCollectionState with _$MoveBookmarksToCollectionState {
  const MoveBookmarksToCollectionState._();

  const factory MoveBookmarksToCollectionState({
    /// List of collections
    required List<Collection> collections,

    /// Selected collection to save at
    Collection? selectedCollection,

    /// Error Message
    String? errorMsg,
  }) = _MoveBookmarksToCollectionState;

  factory MoveBookmarksToCollectionState.initial() =>
      const MoveBookmarksToCollectionState(
        collections: [],
      );

  factory MoveBookmarksToCollectionState.populated({
    required List<Collection> collections,
    required Collection? selectedCollection,
  }) =>
      MoveBookmarksToCollectionState(
        collections: collections,
        selectedCollection: selectedCollection,
      );
}
