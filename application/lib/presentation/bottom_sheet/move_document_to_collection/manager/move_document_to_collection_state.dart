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
    @Default(false) bool isBookmarked,
    String? errorMsg,
  }) = _MoveDocumentToCollectionState;

  factory MoveDocumentToCollectionState.initial() =>
      const MoveDocumentToCollectionState(
        collections: [],
      );
}
