import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class RenameCollectionUseCase
    extends UseCase<RenameCollectionUseCaseParam, None> {
  final CollectionsRepository _collectionsRepository;

  RenameCollectionUseCase(this._collectionsRepository);

  @override
  Stream<None> transaction(RenameCollectionUseCaseParam param) async* {
    final collection = _collectionsRepository.getById(param.collectionId);
    if (collection != null) {
      final updatedCollection = collection.copyWith(name: param.newName);
      _collectionsRepository.collection = updatedCollection;
    }
    yield none;
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
