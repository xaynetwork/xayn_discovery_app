import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:meta/meta.dart';
import 'package:xayn_discovery_app/domain/model/entity.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/utils/hive_db.dart';

abstract class BaseHiveRepository<T extends DbEntity> {
  final Map<dynamic, T> _mapperCache = <dynamic, T>{};
  BaseDbEntityMapper<T> get mapper;

  HiveCrdt<String, dynamic> get recordBox;

  Box<Record> get box;

  /// Date sorted values of the map.
  List<T> get values => box.fastRecordMap().map(_unwrap).toList();

  T _unwrap(Record record) => _mapperCache.putIfAbsent(
      record.value, () => mapper.fromMap(record.value)!);

  bool get isEmpty => values.isEmpty;

  bool get isNotEmpty => values.isNotEmpty;

  List<T> getAll() => values;

  @mustCallSuper
  void clear() => recordBox.clear();
}

abstract class HiveRepository<T extends DbEntity>
    extends BaseHiveRepository<T> {
  HiveCrdt<String, dynamic>? _recordBox;

  @override
  HiveCrdt<String, dynamic> get recordBox =>
      _recordBox ??= HiveCrdt(box, HiveDB.nodeId);

  UniqueId id(T entity) => entity.id;

  T? getById(UniqueId id) => mapper.fromMap(recordBox.get(id.value));

  /// Saves a value to the database.
  void save(T entity) {
    final map = mapper.toMap(entity);
    recordBox.put(id(entity).value, map);
  }

  /// Saves all entities in the order.
  void saveAll(Iterable<T> entities) {
    for (final entity in entities) {
      recordBox.put(id(entity).value, mapper.toMap(entity));
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

  void merge(Map<String, Record<dynamic>> remoteRecords) =>
      recordBox.merge(remoteRecords);

  Map<String, Record<dynamic>> getRecordsForSync({Hlc? modifiedSince}) =>
      recordBox.recordMap(modifiedSince: modifiedSince);
}

extension _BoxExtension<V> on Box<Record<V>> {
  List<Record<V>> fastRecordMap({Hlc? modifiedSince}) {
    final v = values.toList(growable: false);
    final list = <Record<V>>[];

    for (var i = 0, len = v.length, t = modifiedSince?.logicalTime ?? 0;
        i < len;
        i++) {
      final record = v[i];

      if (record.value != null && record.modified.logicalTime >= t) {
        list.add(record);
      }
    }

    return list..sort((recordA, recordB) => recordA.hlc.compareTo(recordB.hlc));
  }
}
