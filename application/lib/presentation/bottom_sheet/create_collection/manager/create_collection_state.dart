import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';

part 'create_collection_state.freezed.dart';

/// Represents the state of the [CreateCollectionManager].
@freezed
class CreateCollectionState with _$CreateCollectionState {
  const CreateCollectionState._();

  const factory CreateCollectionState({
    @Default('') String collectionName,
    Collection? newCollection,
    String? errorMessage,
  }) = _CreateCollectionState;

  factory CreateCollectionState.initial() => const CreateCollectionState();

  factory CreateCollectionState.populateCollection(Collection collection) =>
      CreateCollectionState(
        newCollection: collection,
      );

  factory CreateCollectionState.populateCollectionName(String collectionName) =>
      CreateCollectionState(
        collectionName: collectionName,
      );
}
