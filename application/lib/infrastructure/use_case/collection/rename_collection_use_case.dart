import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class RenameCollectionUseCase
    extends UseCase<RenameCollectionUseCaseParam, Collection> {
  final CollectionsRepository _collectionsRepository;

  RenameCollectionUseCase(this._collectionsRepository);

  @override
  Stream<Collection> transaction(RenameCollectionUseCaseParam param) async* {
    final updatedCollection = param.collection.copyWith(name: param.newName);
    _collectionsRepository.collection = updatedCollection;
    yield updatedCollection;
  }
}

class RenameCollectionUseCaseParam {
  final Collection collection;
  final String newName;

  RenameCollectionUseCaseParam({
    required this.collection,
    required this.newName,
  });
}
