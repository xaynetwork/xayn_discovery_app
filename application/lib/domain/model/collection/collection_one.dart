import 'dart:collection';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../unique_id.dart';

part 'collection_one.freezed.dart';

const kDefaultCollectionId = 'defaultCollectionId';

@freezed
class CollectionOne with _$CollectionOne {
  const CollectionOne._();

  factory CollectionOne({
    required UniqueId id,
    required String name,
    required DateTime updatedAt,
    required ListQueue<UniqueId> itemsIds,
  }) = _CollectionOne;

  factory CollectionOne.readLater({
    required String name,
    DateTime? updatedAt,
    ListQueue<UniqueId>? itemsIds,
  }) =>
      CollectionOne(
        id: readLaterId,
        name: name,
        updatedAt: updatedAt ?? DateTime.now(),
        itemsIds: itemsIds ?? ListQueue(),
      );

  bool get isDefault => id.value == kDefaultCollectionId;

  static UniqueId readLaterId =
      const UniqueId.fromTrustedString('defaultCollectionId');
}
