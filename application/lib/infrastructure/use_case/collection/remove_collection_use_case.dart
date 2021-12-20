import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class RemoveCollectionUseCase extends UseCase<Collection, Collection> {
  final CollectionsRepository _collectionsRepository;

  RemoveCollectionUseCase(this._collectionsRepository);

  @override
  Stream<Collection> transaction(Collection param) async* {
    _collectionsRepository.remove(param);
    yield param;
  }
}
