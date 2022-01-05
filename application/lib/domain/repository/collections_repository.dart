import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

abstract class CollectionsRepository {
  void save(Collection collection);

  /// return the list of collection sorted by [Collection.index]
  List<Collection> getAll();
  Collection? getById(UniqueId id);
  void remove(Collection collection);
  Stream<RepositoryEvent> watch({UniqueId id});
  int getLastCollectionIndex();
  bool isCollectionNameUsed(String name);
}
