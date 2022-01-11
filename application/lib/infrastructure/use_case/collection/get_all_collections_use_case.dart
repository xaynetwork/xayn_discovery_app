import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class GetAllCollectionsUseCase
    extends UseCase<None, GetAllCollectionsUseCaseOut> {
  final CollectionsRepository _collectionsRepository;
  GetAllCollectionsUseCase(this._collectionsRepository);

  @override
  Stream<GetAllCollectionsUseCaseOut> transaction(None param) async* {
    final collections = _collectionsRepository.getAll();
    yield GetAllCollectionsUseCaseOut(collections);
  }
}

class GetAllCollectionsUseCaseOut extends Equatable {
  final List<Collection> collections;

  const GetAllCollectionsUseCaseOut(this.collections);

  @override
  List<Object?> get props => collections;
}
