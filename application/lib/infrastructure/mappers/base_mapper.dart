import 'package:xayn_discovery_app/domain/model/entity.dart';

typedef DbEntityMap = Map<int, dynamic>;

abstract class BaseDbEntityMapper<T extends DbEntity> {
  const BaseDbEntityMapper();
  T? fromMap(DbEntityMap? map);
  DbEntityMap toMap(T entity);
}
