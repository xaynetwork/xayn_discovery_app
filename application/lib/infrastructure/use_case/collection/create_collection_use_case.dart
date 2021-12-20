import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class CreateCollectionUseCase extends UseCase<String, Collection> {
  final CollectionsRepository _collectionsRepository;

  CreateCollectionUseCase(this._collectionsRepository);

  @override
  Stream<Collection> transaction(String param) async* {
    final collectionIndex = _collectionsRepository.getLastCollectionIndex() + 1;
    final collection = Collection(
      id: UniqueId(),
      name: param,
      index: collectionIndex,
    );

    _collectionsRepository.collection = collection;
    yield collection;
  }
}
