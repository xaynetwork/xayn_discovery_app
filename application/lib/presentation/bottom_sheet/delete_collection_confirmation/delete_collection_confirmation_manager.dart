import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';

@injectable
class DeleteCollectionConfirmationManager {
  final RemoveCollectionUseCase _removeCollectionUseCase;

  DeleteCollectionConfirmationManager(
    this._removeCollectionUseCase,
  );

  void removeCollection({
    required UniqueId collectionId,
  }) {
    _removeCollectionUseCase.call(
      RemoveCollectionUseCaseParam(
        collectionIdToRemove: collectionId,
      ),
    );
  }
}
