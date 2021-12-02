abstract class BaseMapper<T> {
  const BaseMapper();
  T? fromMap(Map? map);
  Map toMap(T entity);
}
