import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';

@injectable
class DeleteCollectionConfirmationManager {
  final RemoveCollectionUseCase _removeCollectionUseCase;
  final RemoveBookmarskUseCase _removeBookmarskUseCase;
  final GetAllBookmarksUseCase _getAllBookmarksUseCase;

  late UniqueId _collectionId;

  DeleteCollectionConfirmationManager(
    this._removeCollectionUseCase,
    this._getAllBookmarksUseCase,
    this._removeBookmarskUseCase,
  );

  void init(UniqueId collectionId) => _collectionId = collectionId;

  void deleteAll() async {
    await _removeBookmarskUseCase.call(RemoveBookmarskUseCaseIn(
      bookmarksIds: await retrieveBookmarksIds(),
    ));
    await _removeCollectionUseCase.call(
      RemoveCollectionUseCaseParam(
        collectionIdToRemove: _collectionId,
      ),
    );
  }

  Future<List<UniqueId>> retrieveBookmarksIds() async =>
      (await _getAllBookmarksUseCase.singleOutput(
        GetAllBookmarksUseCaseIn(
          collectionId: _collectionId,
        ),
      ))
          .bookmarks
          .map((e) => e.id)
          .toList();
}
