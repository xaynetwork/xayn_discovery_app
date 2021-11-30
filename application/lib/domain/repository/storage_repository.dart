abstract class StorageRepository<T> {
  Future<void> save(T entity);
  Future<T?> get(String id);
  Future<List<T>> getAll();
  Future<void> remove(T entity);
  Future<void> removeAll(Iterable<String> ids);
}
