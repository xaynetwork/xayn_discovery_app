import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

abstract class CollectionsRepository {
  set collection(Collection collection);
  List<Collection> getAll();
  void remove(Collection collection);
  Stream<RepositoryEvent> watch({UniqueId id});
}
