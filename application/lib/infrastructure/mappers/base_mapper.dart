import 'package:xayn_discovery_app/domain/model/db_entity.dart';

typedef DbEntityMap = Map<int, dynamic>;

abstract class BaseDbEntityMapper<T extends DbEntity> {
  const BaseDbEntityMapper();
  T? fromMap(Map? map);
  DbEntityMap toMap(T entity);

  /// Used to throw a [DbEntityMapperException] in case of error
  /// while mapping an object
  void throwMapperException([
    String exceptionText = 'error occurred while mapping the object',
  ]) =>
      throw DbEntityMapperException(exceptionText);
}

class DbEntityMapperException implements Exception {
  final String msg;

  DbEntityMapperException(this.msg);

  @override
  String toString() => msg;
}
