import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'delete_collection_confirmation_state.freezed.dart';

/// Represents the state of the [MoveBookmarkToCollectionManager].
@freezed
class DeleteCollectionConfirmationState
    with _$DeleteCollectionConfirmationState {
  const DeleteCollectionConfirmationState._();

  const factory DeleteCollectionConfirmationState({
    /// List of bookmarksIds
    required List<UniqueId> bookmarksIds,

    /// Error Message
    String? errorMsg,
  }) = _DeleteCollectionConfirmationState;

  factory DeleteCollectionConfirmationState.initial() =>
      const DeleteCollectionConfirmationState(
        bookmarksIds: [],
      );

  factory DeleteCollectionConfirmationState.populated({
    required List<UniqueId> bookmarksIds,
  }) =>
      DeleteCollectionConfirmationState(
        bookmarksIds: bookmarksIds,
      );
}
