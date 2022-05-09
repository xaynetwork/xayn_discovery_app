import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_card_state.freezed.dart';

@freezed
class CollectionCardState with _$CollectionCardState {
  const CollectionCardState._();

  const factory CollectionCardState({
    /// Number of items that a collection has
    @Default(0) int numOfItems,

    /// The background image of the card
    Uint8List? image,

    /// Error message
    String? errorMsg,
  }) = _CollectionCardState;

  factory CollectionCardState.initial() => const CollectionCardState();

  factory CollectionCardState.populated({
    int numOfItems = 0,
    Uint8List? image,
  }) =>
      CollectionCardState(
        numOfItems: numOfItems,
        image: image,
      );
}
