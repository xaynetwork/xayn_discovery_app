import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmark_to_collection/manager/move_bookmark_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

@injectable
class MoveBookmarkToCollectionManager
    extends Cubit<MoveBookmarkToCollectionState>
    with UseCaseBlocHelper<MoveBookmarkToCollectionState> {
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final MoveBookmarkUseCase _moveBookmarkUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  final GetBookmarkUseCase _getBookmarkUseCase;

  late List<Collection> _collections;
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler;
  Collection? _selectedCollection;

  MoveBookmarkToCollectionManager._(
    this._listenCollectionsUseCase,
    this._moveBookmarkUseCase,
    this._removeBookmarkUseCase,
    this._getBookmarkUseCase,
    this._collections,
  ) : super(MoveBookmarkToCollectionState.initial()) {
    _init();
  }

  @factoryMethod
  static Future<MoveBookmarkToCollectionManager> create(
    GetAllCollectionsUseCase getAllCollectionsUseCase,
    ListenCollectionsUseCase listenCollectionsUseCase,
    MoveBookmarkUseCase moveBookmarkUseCase,
    RemoveBookmarkUseCase removeBookmarkUseCase,
    GetBookmarkUseCase getBookmarkUseCase,
  ) async {
    final collections =
        (await getAllCollectionsUseCase.singleOutput(none)).collections;

    return MoveBookmarkToCollectionManager._(
      listenCollectionsUseCase,
      moveBookmarkUseCase,
      removeBookmarkUseCase,
      getBookmarkUseCase,
      collections,
    );
  }

  void _init() async {
    _collectionsHandler = consume(_listenCollectionsUseCase, initialData: none);
  }

  Future<void> updateInitialSelectedCollection({
    required UniqueId bookmarkId,
    Collection? forceSelectCollection,
  }) async {
    if (forceSelectCollection != null) {
      updateSelectedCollection(forceSelectCollection);
      return;
    }

    late Bookmark bookmark;
    try {
      bookmark = await _getBookmarkUseCase.singleOutput(bookmarkId);
    } catch (e) {
      return;
    }

    final selectedCollection = _collections.firstWhere(
      (it) => it.id == bookmark.collectionId,
    );
    updateSelectedCollection(selectedCollection);
  }

  void updateSelectedCollection(Collection? collection) =>
      scheduleComputeState(() => _selectedCollection = collection);

  void onApplyPressed({required UniqueId bookmarkId}) {
    if (state.selectedCollection == null) {
      _removeBookmarkUseCase.call(bookmarkId);
    } else {
      _moveBookmarkToSelectedCollection(bookmarkId: bookmarkId);
    }
  }

  void _moveBookmarkToSelectedCollection({required UniqueId bookmarkId}) {
    final param = MoveBookmarkUseCaseIn(
      bookmarkId: bookmarkId,
      collectionId: state.selectedCollection!.id,
    );
    _moveBookmarkUseCase.call(param);
  }

  @override
  Future<MoveBookmarkToCollectionState?> computeState() async =>
      fold(_collectionsHandler).foldAll((usecaseOut, errorReport) {
        if (errorReport.isNotEmpty) {
          final error = errorReport.of(_collectionsHandler)!.error;
          logger.e(error);
          return state.copyWith(errorMsg: error.toString());
        }

        if (usecaseOut != null) {
          _collections = usecaseOut.collections;
        }

        final newState = MoveBookmarkToCollectionState.populated(
          collections: _collections,
          selectedCollection: _selectedCollection,
        );

        return newState;
      });
}
