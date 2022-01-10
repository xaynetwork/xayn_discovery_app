import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_card_state.freezed.dart';

@freezed
class CollectionCardState with _$CollectionCardState {
  const CollectionCardState._();

  const factory CollectionCardState({
    @Default(0) int numOfItems,
    Uint8List? image,
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
