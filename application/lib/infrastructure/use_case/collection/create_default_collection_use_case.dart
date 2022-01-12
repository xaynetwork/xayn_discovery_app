import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_outputs.dart';

@injectable
class CreateDefaultCollectionUseCase
    extends UseCase<String, CollectionUseCaseGenericOut> {
  final CollectionsRepository _collectionsRepository;

  CreateDefaultCollectionUseCase(this._collectionsRepository);
  @override
  Stream<CollectionUseCaseGenericOut> transaction(String param) async* {
    assert(
      param.isNotEmpty,
    );

    final collections = _collectionsRepository.getAll();

    /// Check if the default collection already exists.
    if (collections
        .where(
          (element) => element.id == Collection.readLaterId,
        )
        .isNotEmpty) {
      yield const CollectionUseCaseGenericOut.failure(
          CollectionUseCaseErrorEnum.tryingToCreateAgainDefaultCollection);
      return;
    }

    final collection = Collection.readLater(name: param.trim());
    _collectionsRepository.save(collection);

    yield CollectionUseCaseGenericOut.success(collection);
  }
}
