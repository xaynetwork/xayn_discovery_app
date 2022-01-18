import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class CreateOrGetDefaultCollectionUseCase extends UseCase<String, Collection> {
  final CollectionsRepository _collectionsRepository;

  CreateOrGetDefaultCollectionUseCase(this._collectionsRepository);

  @override
  Stream<Collection> transaction(String param) async* {
    assert(
      param.isNotEmpty,
    );

    final collections = _collectionsRepository.getAll();

    final Collection collection = collections.firstWhere((it) => it.isDefault,
        orElse: () => createCollection(param));

    yield collection;
  }

  Collection createCollection(String name) {
    final collection = Collection.readLater(name: name.trim());
    _collectionsRepository.save(collection);
    return collection;
  }
}
