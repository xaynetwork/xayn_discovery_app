import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

import 'collection_exception.dart';

@injectable
class CreateCollectionUseCase extends UseCase<String, Collection> {
  final CollectionsRepository _collectionsRepository;
  final UniqueIdHandler _uniqueIdHandler;

  CreateCollectionUseCase(this._collectionsRepository, this._uniqueIdHandler);

  @override
  Stream<Collection> transaction(String param) async* {
    if (_collectionsRepository.isCollectionNameUsed(param)) {
      logger.e(errorMessageCollectionNameUsed);
      throw (CollectionUseCaseException(errorMessageCollectionNameUsed));
    }
    final collectionIndex = _collectionsRepository.getLastCollectionIndex() + 1;
    final id = _uniqueIdHandler.generateUniqueId();
    final collection = Collection(
      id: id,
      name: param,
      index: collectionIndex,
    );

    _collectionsRepository.save(collection);
    yield collection;
  }
}
