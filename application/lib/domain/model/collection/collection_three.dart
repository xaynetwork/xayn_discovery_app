import 'package:freezed_annotation/freezed_annotation.dart';

import '../unique_id.dart';

part 'collection_three.freezed.dart';

const kDefaultCollectionId = 'defaultCollectionId';

@freezed
class CollectionThree with _$CollectionThree {
  const CollectionThree._();

  factory CollectionThree({
    required UniqueId id,
    required String name,
    required DateTime updatedAt,
  }) = _CollectionThree;

  factory CollectionThree.readLater({
    required String name,
    DateTime? updatedAt,
  }) =>
      CollectionThree(
        id: readLaterId,
        name: name,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  bool get isDefault => id.value == kDefaultCollectionId;

  static UniqueId readLaterId =
      const UniqueId.fromTrustedString('defaultCollectionId');
}
