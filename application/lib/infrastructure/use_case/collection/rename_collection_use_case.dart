import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

import 'collection_use_cases_outputs.dart';

@injectable
class RenameCollectionUseCase
    extends UseCase<RenameCollectionUseCaseParam, CollectionUseCaseGenericOut> {
  final CollectionsRepository _collectionsRepository;

  RenameCollectionUseCase(this._collectionsRepository);

  @override
  Stream<CollectionUseCaseGenericOut> transaction(
      RenameCollectionUseCaseParam param) async* {
    final collectionNameTrimmed = param.newName.trim();
    if (_collectionsRepository.isCollectionNameUsed(collectionNameTrimmed)) {
      yield const CollectionUseCaseGenericOut.failure(
          CollectionUseCaseErrorEnum.tryingToRenameCollectionUsingExistingName);
      return;
    }

    final collection = _collectionsRepository.getById(param.collectionId);

    if (collection == null) {
      yield const CollectionUseCaseGenericOut.failure(
          CollectionUseCaseErrorEnum.tryingToRenameNotExistingCollection);
      return;
    }

    final updatedCollection = collection.copyWith(name: collectionNameTrimmed);
    _collectionsRepository.save(updatedCollection);

    yield CollectionUseCaseGenericOut.success(collection);
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
