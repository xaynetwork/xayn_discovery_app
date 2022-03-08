import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_or_get_default_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_collection_use_case.dart';

@injectable
class RenameDefaultCollectionUseCase extends UseCase<String, Collection> {
  final CreateOrGetDefaultCollectionUseCase
      _createOrGetDefaultCollectionUseCase;
  final RenameCollectionUseCase _renameCollectionUseCase;

  RenameDefaultCollectionUseCase(
    this._createOrGetDefaultCollectionUseCase,
    this._renameCollectionUseCase,
  );
  @override
  Stream<Collection> transaction(String param) async* {
    assert(
      param.isNotEmpty,
    );

    final defaultCollection =
        await _createOrGetDefaultCollectionUseCase.singleOutput(param);

    await _renameCollectionUseCase.singleOutput(
      RenameCollectionUseCaseParam(
        collectionId: defaultCollection.id,
        newName: param,
      ),
    );
  }
}
