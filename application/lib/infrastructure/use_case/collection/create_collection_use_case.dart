import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';

import 'collection_use_cases_outputs.dart';

@injectable
class CreateCollectionUseCase
    extends UseCase<String, CollectionUseCaseGenericOut> {
  final CollectionsRepository _collectionsRepository;
  final UniqueIdHandler _uniqueIdHandler;

  CreateCollectionUseCase(this._collectionsRepository, this._uniqueIdHandler);

  @override
  Stream<CollectionUseCaseGenericOut> transaction(String param) async* {
    final collectionNameTrimmed = param.trim();
    if (_collectionsRepository.isCollectionNameUsed(collectionNameTrimmed)) {
      yield const CollectionUseCaseGenericOut.failure(
        CollectionUseCaseErrorEnum.tryingToCreateCollectionUsingExistingName,
      );
      return;
    }
    final collectionIndex = _collectionsRepository.getLastCollectionIndex() + 1;
    final id = _uniqueIdHandler.generateUniqueId();
    final collection = Collection(
      id: id,
      name: collectionNameTrimmed,
      index: collectionIndex,
    );

    _collectionsRepository.save(collection);
    yield CollectionUseCaseGenericOut.success(collection);
  }
}
