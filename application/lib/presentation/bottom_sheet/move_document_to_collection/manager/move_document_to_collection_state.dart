import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';

part 'move_document_to_collection_state.freezed.dart';

/// Represents the state of the [CollectionBottomSheetManager].
@freezed
class MoveDocumentToCollectionState with _$MoveDocumentToCollectionState {
  const MoveDocumentToCollectionState._();

  const factory MoveDocumentToCollectionState({
    required List<Collection> collections,
    Collection? selectedCollection,
    String? errorMsg,
    @Default(false) bool isBookmarked,
  }) = _MoveDocumentToCollectionState;

  factory MoveDocumentToCollectionState.initial() =>
      const MoveDocumentToCollectionState(
        collections: [],
      );

  factory MoveDocumentToCollectionState.populated({
    required List<Collection> collections,
    required Collection? selectedCollection,
    required bool isBookmarked,
  }) =>
      MoveDocumentToCollectionState(
        collections: collections,
        selectedCollection: selectedCollection,
        isBookmarked: isBookmarked,
      );
}
