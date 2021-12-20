import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';

import '../unique_id.dart';

part 'collection.freezed.dart';

const kDefaultCollectionId = 'defaultCollectionId';

@freezed
class Collection extends DbEntity with _$Collection {
  @Assert('name.isNotEmpty', 'name cannot be empty')
  @Assert('index >= 0', 'index cannot be smaller than 0')
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

  /// This is the id of the default collection.
  /// The default collection cannot be deleted or renamed.
  static UniqueId readLaterId =
      const UniqueId.fromTrustedString('defaultCollectionId');
}

/// Why this extension is needed ?
/// Getters of classes decorated with @freezed require a MyClass._() constructor
/// Classes decorated with @freezed can only have a single non-factory, without parameters, and named MyClass._()
/// In our case we would need a const Collection._(Unique id):super(id) constructor, but it's not possible
/// to have parameter in that constructor, as mentioned above.
/// Therefore we need extension
extension CollectionExtension on Collection {
  bool get isDefault => id.value == kDefaultCollectionId;
}
