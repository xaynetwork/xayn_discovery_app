import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

import 'collection_exception.dart';

@injectable
class CreateDefaultCollectionUseCase extends UseCase<String, Collection> {
  final CollectionsRepository _collectionsRepository;

  CreateDefaultCollectionUseCase(this._collectionsRepository);
  @override
  Stream<Collection> transaction(String param) async* {
    assert(
      param.isNotEmpty,
      errorMsgCollectionNameEmpty,
    );

    final collections = _collectionsRepository.getAll();

    /// Check if the default collection already exists.
    if (collections
        .where(
          (element) => element.id == Collection.readLaterId,
        )
        .isNotEmpty) {
      logger.e(toString() + ': ' + errorMsgCollectionAlreadyExists);
      throw CreateDefaultCollectionUseCaseException(
        errorMsgCollectionAlreadyExists,
      );
    }

    final collection = Collection.readLater(name: param.trim());
    _collectionsRepository.save(collection);

    yield collection;
  }
}
