import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';

import '../unique_id.dart';

part 'collection.freezed.dart';

const kDefaultCollectionId = 'defaultCollectionId';

@freezed
class Collection with _$Collection {
  const Collection._();

  @Implements<DbEntity>()
  factory Collection({
    required UniqueId id,
    required String name,
    required int index,
  }) = _Collection;

  factory Collection.readLater({
    required String name,
  }) =>
      Collection(
        index: 0,
        id: Collection.readLaterId,
        name: name,
      );

  bool get isDefault => id.value == kDefaultCollectionId;

  static UniqueId readLaterId =
      const UniqueId.fromTrustedString('defaultCollectionId');
}
