import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';

part 'move_bookmark_to_collection_state.freezed.dart';

/// Represents the state of the [CollectionBottomSheetManager].
@freezed
class MoveBookmarkToCollectionState with _$MoveBookmarkToCollectionState {
  const MoveBookmarkToCollectionState._();

  const factory MoveBookmarkToCollectionState({
    /// List of collections
    required List<Collection> collections,

    /// Selected collection to save at
    Collection? selectedCollection,

    /// Error Message
    String? errorMsg,
  }) = _MoveBookmarkToCollectionState;

  factory MoveBookmarkToCollectionState.initial() =>
      const MoveBookmarkToCollectionState(
        collections: [],
      );
}
