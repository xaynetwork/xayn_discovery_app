import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:meta/meta.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';

/// Repository interface for storing Hive entities.
abstract class BaseHiveRepository<T extends DbEntity> {
  final Map<dynamic, T> _mapperCache = <dynamic, T>{};

  /// The mapper used to serialize and deserialize entity object to and from [Map].
  BaseDbEntityMapper<T> get mapper;

  /// The CRDT version of Hive box.
  HiveCrdt<String, dynamic> get recordBox;

  /// The Hive box.
  Box<Record> get box;

  /// All unwrapped items in the box.
  List<T> get _values => box.values.map(_unwrap).toList();

  /// The helper mapper method to ensure that [Record] always has a corresponding value.
  T _unwrap(Record record) => _mapperCache.putIfAbsent(
      record.value, () => mapper.fromMap(record.value)!);

  /// Checks if the box is empty.
  bool get isEmpty => _values.isEmpty;

  /// Checks if the box is not empty.
  bool get isNotEmpty => _values.isNotEmpty;

  /// Gets all items from the box.
  List<T> getAll() => _values;

  /// Removes all items from the box.
  @mustCallSuper
  void clear() => recordBox.clear();
}

/// A CRUD interface for Hive repository.
abstract class HiveRepository<T extends DbEntity>
    extends BaseHiveRepository<T> {
  HiveCrdt<String, dynamic>? _recordBox;

  @override
  HiveCrdt<String, dynamic> get recordBox =>
      _recordBox ??= HiveCrdt(box, HiveDB.nodeId);

  /// The helper method that returns an id from a given entity.
  UniqueId _id(T entity) => entity.id;

  /// Fetches an entity from the database by a given id.
  T? getById(UniqueId id) => mapper.fromMap(recordBox.get(id.value));

  /// Saves or update a value in the database.
  void save(T entity) {
    final map = mapper.toMap(entity);
    recordBox.put(_id(entity).value, map);
  }

  /// Saves all entities in the order.
  void saveAll(Iterable<T> entities) {
    for (final entity in entities) {
      recordBox.put(_id(entity).value, mapper.toMap(entity));
    }
  }

  /// Removes an entity from the database.
  void remove(T entity) {
    final id = entity.id.value;
    recordBox.delete(id);
  }

  /// Removes all entities from the database for a given [ids].
  void removeAll(Iterable<UniqueId> ids) {
    for (final id in ids) {
      recordBox.delete(id.value);
    }
  }

  /// Alias for removeAll.
  void removeAllByIds(Iterable<UniqueId> ids) => removeAll(ids);

  /// Actually purges all elements including null/ tombstone values, should only be used for testing purposes.
  @visibleForTesting
  void purgeAll() => recordBox.clear(purge: true);

  List<T> getAllByIds(Iterable<UniqueId> ids) => ids
      .map((id) => mapper.fromMap(recordBox.get(id.value)))
      .where((element) => element != null)
      .cast<T>()
      .toList(growable: false);

  /// Returns a broadcast stream of change events.
  ///
  /// If the [id] parameter is provided, only events for the specified id are
  /// broadcasted.
  Stream<RepositoryEvent<T>> watch({UniqueId? id}) {
    return recordBox.watch().map((event) {
      final obj = mapper.fromMap(event.value);
      final uniqueId =
          obj is DbEntity ? obj.id : UniqueId.fromTrustedString(event.key);

      return RepositoryEvent.from(obj, uniqueId);
    }).where((event) {
      if (id != null) {
        return event.id == id;
      } else {
        return true;
      }
    }).cast();
  }
}
