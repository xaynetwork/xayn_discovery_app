import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_collection_state.freezed.dart';

/// Represents the state of the [CreateCollectionManager].
@freezed
class CreateCollectionState with _$CreateCollectionState {
  const CreateCollectionState._();

  const factory CreateCollectionState({
    @Default('') String collectionName,
    String? errorMessage,
  }) = _CreateCollectionState;
}
