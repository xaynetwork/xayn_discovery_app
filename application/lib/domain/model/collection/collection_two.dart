import 'package:freezed_annotation/freezed_annotation.dart';

import '../unique_id.dart';

part 'collection_two.freezed.dart';

const kDefaultCollectionId = 'defaultCollectionId';

@freezed
class CollectionTwo with _$CollectionTwo {
  const CollectionTwo._();

  factory CollectionTwo({
    required UniqueId id,
    required String name,
    required DateTime updatedAt,
    required int numOfItems,
    required String? imageUrl,
  }) = _CollectionTwo;

  factory CollectionTwo.readLater({
    required String name,
    DateTime? updatedAt,
    String? imageUrl,
    int? numOfItems,
  }) =>
      CollectionTwo(
        id: readLaterId,
        name: name,
        updatedAt: updatedAt ?? DateTime.now(),
        imageUrl: imageUrl,
        numOfItems: numOfItems ?? 0,
      );

  bool get isDefault => id.value == kDefaultCollectionId;

  static UniqueId readLaterId =
      const UniqueId.fromTrustedString('defaultCollectionId');
}
