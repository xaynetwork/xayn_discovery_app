import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';

@injectable
class CreateCollectionManager {
  final CreateCollectionUseCase _createCollectionUseCase;

  CreateCollectionManager(
    this._createCollectionUseCase,
  );

  Future<Collection> createCollection(String collectionName) =>
      _createCollectionUseCase.singleOutput(collectionName);
}
