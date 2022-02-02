import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';

@injectable
class DeleteCollectionConfirmationManager {
  final RemoveCollectionUseCase _removeCollectionUseCase;
  final GetAllBookmarksUseCase _getAllBookmarksUseCase;

  DeleteCollectionConfirmationManager(
    this._removeCollectionUseCase,
    this._getAllBookmarksUseCase,
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

  Future<List<UniqueId>> retrieveBookmarksIdsByCollectionId(
          UniqueId collectionId) async =>
      (await _getAllBookmarksUseCase.singleOutput(
        GetAllBookmarksUseCaseIn(
          collectionId: collectionId,
        ),
      ))
          .bookmarks
          .map((e) => e.id)
          .toList();
}
