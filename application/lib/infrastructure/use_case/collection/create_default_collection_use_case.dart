import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class CreateDefaultCollectionUseCase extends UseCase<String, None> {
  final CollectionsRepository _collectionsRepository;

  CreateDefaultCollectionUseCase(this._collectionsRepository);
  @override
  Stream<None> transaction(String param) async* {
    assert(
        param.isNotEmpty, 'The name of the default collection cannot be empty');

    final collections = _collectionsRepository.getAll();

    /// Check that the default collection doesn't already exist.
    if (collections
        .where(
          (element) => element.id == Collection.readLaterId,
        )
        .isEmpty) {
      final collection = Collection.readLater(name: param);
      _collectionsRepository.collection = collection;
    }
    yield none;
  }
}
