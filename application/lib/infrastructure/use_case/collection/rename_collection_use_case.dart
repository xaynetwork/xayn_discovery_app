import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

import 'collection_exception.dart';

@injectable
class RenameCollectionUseCase
    extends UseCase<RenameCollectionUseCaseParam, Collection?> {
  final CollectionsRepository _collectionsRepository;

  RenameCollectionUseCase(this._collectionsRepository);

  @override
  Stream<Collection?> transaction(RenameCollectionUseCaseParam param) async* {
    final collectionNameTrimmed = param.newName.trim();
    if (_collectionsRepository.isCollectionNameUsed(collectionNameTrimmed)) {
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

    final updatedCollection = collection.copyWith(name: collectionNameTrimmed);
    _collectionsRepository.save(updatedCollection);

    yield updatedCollection;
  }
}

class RenameCollectionUseCaseParam extends Equatable {
  final UniqueId collectionId;
  final String newName;

  const RenameCollectionUseCaseParam({
    required this.collectionId,
    required this.newName,
  });

  @override
  List<Object?> get props => [collectionId, newName];
}
