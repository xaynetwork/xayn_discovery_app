import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_collection_confirmation_state.freezed.dart';

/// Represents the state of the [MoveBookmarkToCollectionManager].
@freezed
class DeleteCollectionConfirmationState
    with _$DeleteCollectionConfirmationState {
  const DeleteCollectionConfirmationState._();

  const factory DeleteCollectionConfirmationState({
    /// List of bookmarksUrls
    required List<String> bookmarksUrls,

    /// Error Message
    String? errorMsg,
  }) = _DeleteCollectionConfirmationState;

  factory DeleteCollectionConfirmationState.initial() =>
      const DeleteCollectionConfirmationState(
        bookmarksUrls: [],
      );

  factory DeleteCollectionConfirmationState.populated({
    required List<String> bookmarksUrls,
  }) =>
      DeleteCollectionConfirmationState(
        bookmarksUrls: bookmarksUrls,
      );
}
