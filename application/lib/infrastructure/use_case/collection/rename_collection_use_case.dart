import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

import 'collection_exception.dart';

@injectable
class RenameCollectionUseCase
    extends UseCase<RenameCollectionUseCaseParam, Collection> {
  final CollectionsRepository _collectionsRepository;

  RenameCollectionUseCase(this._collectionsRepository);

  @override
  Stream<Collection> transaction(RenameCollectionUseCaseParam param) async* {
    /// Check if we're trying to rename the default collection
    if (param.collectionId == Collection.readLaterId) {
      logger.e(errorMessageRenamingDefaultCollection);
      throw CollectionUseCaseException(
        errorMessageRenamingDefaultCollection,
      );
    }

    final collection = _collectionsRepository.getById(param.collectionId);

    /// Check if collection exists
    if (collection == null) {
      logger.e(errorMessageRenamingNotExistingCollection);
      throw CollectionUseCaseException(
        errorMessageRenamingNotExistingCollection,
      );
    }

    final updatedCollection = collection.copyWith(name: param.newName);
    _collectionsRepository.collection = updatedCollection;

    yield updatedCollection;
  }
}

class RenameCollectionUseCaseParam {
  final UniqueId collectionId;
  final String newName;

  RenameCollectionUseCaseParam({
    required this.collectionId,
    required this.newName,
  });
}
