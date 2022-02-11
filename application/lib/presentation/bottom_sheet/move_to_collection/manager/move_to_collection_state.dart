import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';

part 'move_to_collection_state.freezed.dart';

/// Represents the state of the [MoveToCollectionManager].
@freezed
class MoveToCollectionState with _$MoveToCollectionState {
  const MoveToCollectionState._();

  const factory MoveToCollectionState({
    required List<Collection> collections,
    Collection? selectedCollection,
    Object? errorObj,
    @Default(false) bool isBookmarked,
    @Default(false) bool shouldClose,
  }) = _MoveToCollectionState;

  factory MoveToCollectionState.initial() => const MoveToCollectionState(
        collections: [],
      );

  factory MoveToCollectionState.populated({
    required List<Collection> collections,
    required Collection? selectedCollection,
    required bool isBookmarked,
    required bool shouldClose,
  }) =>
      MoveToCollectionState(
        collections: collections,
        selectedCollection: selectedCollection,
        isBookmarked: isBookmarked,
        shouldClose: shouldClose,
      );
}

extension MoveDocumentToCollectionStateExtension on MoveToCollectionState {
  bool get hasError => errorObj != null;
}
