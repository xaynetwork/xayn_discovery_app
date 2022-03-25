import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

import 'collection_use_cases_errors.dart';

@injectable
class RenameCollectionUseCase
    extends UseCase<RenameCollectionUseCaseParam, Collection> {
  final CollectionsRepository _collectionsRepository;

  RenameCollectionUseCase(this._collectionsRepository);

  @override
  Stream<Collection> transaction(RenameCollectionUseCaseParam param) async* {
    final collectionNameTrimmed = param.newName.trim();

    if (_collectionsRepository
        .isCollectionNameNotValid(collectionNameTrimmed)) {
      throw CollectionUseCaseError.tryingToRenameCollectionWithInvalidName;
    }

    final collection = _collectionsRepository.getById(param.collectionId);

    if (collection == null) {
      throw CollectionUseCaseError.tryingToRenameNotExistingCollection;
    }

    if (collection.name == collectionNameTrimmed) {
      yield collection;
      return;
    }

    if (_collectionsRepository.isCollectionNameUsed(collectionNameTrimmed)) {
      throw CollectionUseCaseError.tryingToRenameCollectionUsingExistingName;
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
  List<Object> get props => [collectionId, newName];
}
