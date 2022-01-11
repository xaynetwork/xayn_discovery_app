import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';

part 'collections_screen_state.freezed.dart';

@freezed
class CollectionsScreenState with _$CollectionsScreenState {
  const CollectionsScreenState._();

  const factory CollectionsScreenState({
    /// List of collections
    required List<Collection> collections,

    /// Timestamp of update time (for making sure that state is emitted)
    required DateTime timestamp,

    /// Error Message
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
