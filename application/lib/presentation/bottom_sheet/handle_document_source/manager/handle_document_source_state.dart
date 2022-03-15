import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_architecture/concepts/navigation/navigator_state.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'handle_document_source_manager.freezed.dart';

@freezed
class HandleDocumentSourceState with _$HandleDocumentSourceState {
  const HandleDocumentSourceState._();

  const factory HandleDocumentSourceState({
    required List<Source> collections,
    UniqueId? selectedCollectionId,
    Object? errorObj,
    @Default(false) bool isBookmarked,
    @Default(false) bool shouldClose,
  }) = _MoveToCollectionState;

  factory MoveToCollectionState.initial() => const MoveToCollectionState(
        collections: [],
      );

  factory MoveToCollectionState.populated({
    required List<Collection> collections,
    required UniqueId? selectedCollectionId,
    required bool isBookmarked,
    required bool shouldClose,
  }) =>
      MoveToCollectionState(
        collections: collections,
        selectedCollectionId: selectedCollectionId,
        isBookmarked: isBookmarked,
        shouldClose: shouldClose,
      );
}
