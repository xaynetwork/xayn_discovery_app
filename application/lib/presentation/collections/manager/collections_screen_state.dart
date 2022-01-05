import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';

part 'collections_screen_state.freezed.dart';

@freezed
class CollectionsScreenState with _$CollectionsScreenState {
  const CollectionsScreenState._();

  const factory CollectionsScreenState({
    required List<Collection> collections,
    required DateTime timestamp,
    String? errorMsg,
  }) = _CollectionsScreenState;

  factory CollectionsScreenState.initial() => CollectionsScreenState(
        collections: const [],
        timestamp: DateTime.now(),
      );

  factory CollectionsScreenState.populated(
    List<Collection> collections,
    DateTime timestamp,
  ) =>
      CollectionsScreenState(
        collections: collections,
        timestamp: timestamp,
      );
}
