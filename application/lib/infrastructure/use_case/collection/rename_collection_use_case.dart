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
    if (_collectionsRepository.isCollectionNameUsed(param.newName)) {
      logger.e(errorMessageCollectionNameUsed);
      throw CollectionUseCaseException(
        errorMessageCollectionNameUsed,
      );
    }

    final collection = _collectionsRepository.getById(param.collectionId);

    if (collection == null) {
      logger.e(errorMessageRenamingNotExistingCollection);
      throw CollectionUseCaseException(
        errorMessageRenamingNotExistingCollection,
      );
    }

    final updatedCollection = collection.copyWith(name: param.newName);
    _collectionsRepository.save(updatedCollection);

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
