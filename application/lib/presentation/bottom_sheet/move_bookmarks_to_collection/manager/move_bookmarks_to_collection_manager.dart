import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

import 'move_bookmarks_to_collection_state.dart';

@injectable
class MoveBookmarksToCollectionManager
    extends Cubit<MoveBookmarksToCollectionState>
    with UseCaseBlocHelper<MoveBookmarksToCollectionState> {
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final MoveBookmarksUseCase _moveBookmarksUseCase;
  final RemoveCollectionUseCase _removeCollectionUseCase;
  final GetAllCollectionsUseCase _getAllCollectionsUseCase;

  final List<Collection> _collections = [];
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler =
      consume(_listenCollectionsUseCase, initialData: none);
  Collection? _selectedCollection;

  MoveBookmarksToCollectionManager(
    this._listenCollectionsUseCase,
    this._moveBookmarksUseCase,
    this._removeCollectionUseCase,
    this._getAllCollectionsUseCase,
  ) : super(MoveBookmarksToCollectionState.initial());

  void enteringScreen({
    required UniqueId collectionIdToRemove,
    Collection? selectedCollection,
  }) async {
    final useCaseResult = await _getAllCollectionsUseCase.singleOutput(none);
    _collections
      ..clear()
      ..addAll(useCaseResult.collections);

    _collections.removeWhere((element) => element.id == collectionIdToRemove);
    scheduleComputeState(
      () => _selectedCollection = selectedCollection ?? _collections.first,
    );
  }

  void updateSelectedCollection(Collection? collection) {
    if (collection == null) return;
    scheduleComputeState(() => _selectedCollection = collection);
  }

  Future<void> onApplyPressed({
    required List<UniqueId> bookmarksIds,
    required UniqueId collectionIdToRemove,
  }) async {
    await _moveBookmarksUseCase.call(
      MoveBookmarksUseCaseIn(
        bookmarkIds: bookmarksIds,
        collectionId: state.selectedCollection!.id,
      ),
    );
    _removeCollectionUseCase.call(
      RemoveCollectionUseCaseParam(
        collectionIdToRemove: collectionIdToRemove,
      ),
    );
  }

  @override
  Future<MoveBookmarksToCollectionState?> computeState() async =>
      fold(_collectionsHandler).foldAll((usecaseOut, errorReport) {
        if (errorReport.isNotEmpty) {
          final error = errorReport.of(_collectionsHandler)!.error;
          logger.e(error);
          return state.copyWith(errorMsg: error.toString());
        }

        if (usecaseOut != null) {
          _collections
            ..clear()
            ..addAll(usecaseOut.collections);
        }

        final newState = MoveBookmarksToCollectionState.populated(
          collections: _collections,
          selectedCollection: _selectedCollection,
        );

        return newState;
      });
}
