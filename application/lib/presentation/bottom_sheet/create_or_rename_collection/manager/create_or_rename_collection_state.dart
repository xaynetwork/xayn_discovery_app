import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';

part 'create_or_rename_collection_state.freezed.dart';

/// Represents the state of the [CreateOrRenameCollectionManager].
@freezed
class CreateOrRenameCollectionState with _$CreateOrRenameCollectionState {
  const CreateOrRenameCollectionState._();

  const factory CreateOrRenameCollectionState({
    @Default('') String collectionName,
    Collection? newCollection,
    @Default(ErrorObject()) ErrorObject error,
  }) = _CreateOrRenameCollectionState;

  factory CreateOrRenameCollectionState.initial() =>
      const CreateOrRenameCollectionState();

  factory CreateOrRenameCollectionState.populateCollection(
          Collection collection) =>
      CreateOrRenameCollectionState(
        newCollection: collection,
      );

  factory CreateOrRenameCollectionState.populateCollectionName(
          String collectionName) =>
      CreateOrRenameCollectionState(
        collectionName: collectionName,
      );
}
