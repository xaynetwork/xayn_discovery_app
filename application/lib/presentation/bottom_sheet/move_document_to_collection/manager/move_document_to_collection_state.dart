import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';

part 'move_document_to_collection_state.freezed.dart';

/// Represents the state of the [MoveDocumentToCollectionManager].
@freezed
class MoveDocumentToCollectionState with _$MoveDocumentToCollectionState {
  const MoveDocumentToCollectionState._();

  const factory MoveDocumentToCollectionState({
    required List<Collection> collections,
    Collection? selectedCollection,
    Object? errorObj,
    @Default(false) bool isBookmarked,
    @Default(false) bool shouldClose,
  }) = _MoveDocumentToCollectionState;

  factory MoveDocumentToCollectionState.initial() =>
      const MoveDocumentToCollectionState(
        collections: [],
      );

  factory MoveDocumentToCollectionState.populated({
    required List<Collection> collections,
    required Collection? selectedCollection,
    required bool isBookmarked,
    required bool shouldClose,
  }) =>
      MoveDocumentToCollectionState(
        collections: collections,
        selectedCollection: selectedCollection,
        isBookmarked: isBookmarked,
        shouldClose: shouldClose,
      );
}

extension MoveDocumentToCollectionStateExtension
    on MoveDocumentToCollectionState {
  bool get hasError => errorObj != null;
}
