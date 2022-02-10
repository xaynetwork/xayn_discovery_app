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

  List<Collection> _collections = [];
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler;
  Collection? _selectedCollection;

  MoveBookmarksToCollectionManager(
    this._listenCollectionsUseCase,
    this._moveBookmarksUseCase,
    this._removeCollectionUseCase,
    this._getAllCollectionsUseCase,
  ) : super(MoveBookmarksToCollectionState.initial()) {
    _init();
  }

  void _init() {
    _collectionsHandler = consume(_listenCollectionsUseCase, initialData: none);
  }

  void enteringScreen({
    required UniqueId collectionIdToRemove,
    Collection? selectedCollection,
  }) async {
    _collections =
        (await _getAllCollectionsUseCase.singleOutput(none)).collections;
    _collections.removeWhere((element) => element.id == collectionIdToRemove);
    scheduleComputeState(
      () {
        if (selectedCollection != null) {
          _selectedCollection = selectedCollection;
        } else {
          _selectedCollection = _collections.first;
        }
      },
    );
  }

  void updateSelectedCollection(Collection? collection) {
    if (collection != null) {
      scheduleComputeState(() => _selectedCollection = collection);
    }
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
          _collections = usecaseOut.collections;
        }

        final newState = MoveBookmarksToCollectionState.populated(
          collections: _collections,
          selectedCollection: _selectedCollection,
        );

        return newState;
      });
}
