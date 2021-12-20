import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class CreateDefaultCollectionUseCase extends UseCase<String?, Collection> {
  final CollectionsRepository _collectionsRepository;

  CreateDefaultCollectionUseCase(this._collectionsRepository);
  @override
  Stream<Collection> transaction(String? param) async* {
    // TODO Replace hardcoded String
    final collection = Collection.readLater(name: param ?? 'Read Later');
    _collectionsRepository.collection = collection;
    yield collection;
  }
}
