import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class GetAllCollectionsUseCase extends UseCase<None, List<Collection>> {
  final CollectionsRepository _collectionsRepository;
  GetAllCollectionsUseCase(this._collectionsRepository);

  @override
  Stream<List<Collection>> transaction(None param) async* {
    yield _collectionsRepository.getAll();
  }
}
