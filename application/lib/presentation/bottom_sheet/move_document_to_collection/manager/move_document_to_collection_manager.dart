import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/is_bookmarked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_document_to_collection/manager/move_document_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';

@injectable
class MoveDocumentToCollectionManager
    extends Cubit<MoveDocumentToCollectionState>
    with UseCaseBlocHelper<MoveDocumentToCollectionState> {
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final MoveBookmarkUseCase _moveBookmarkUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  final CreateBookmarkFromDocumentUseCase _createBookmarkUseCase;
  final GetBookmarkUseCase _getBookmarkUseCase;
  final IsBookmarkedUseCase _isBookmarkedUseCase;

  late List<Collection> _collections;
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler;
  Collection? _selectedCollection;

  MoveDocumentToCollectionManager._(
    this._listenCollectionsUseCase,
    this._moveBookmarkUseCase,
    this._removeBookmarkUseCase,
    this._getBookmarkUseCase,
    this._isBookmarkedUseCase,
    this._createBookmarkUseCase,
    this._collections,
  ) : super(MoveDocumentToCollectionState.initial()) {
    _init();
  }

  @factoryMethod
  static Future<MoveDocumentToCollectionManager> create(
    GetAllCollectionsUseCase getAllCollectionsUseCase,
    ListenCollectionsUseCase listenCollectionsUseCase,
    MoveBookmarkUseCase moveBookmarkUseCase,
    RemoveBookmarkUseCase removeBookmarkUseCase,
    GetBookmarkUseCase getBookmarkUseCase,
    CreateBookmarkFromDocumentUseCase createBookmarkUseCase,
    IsBookmarkedUseCase isBookmarkedUseCase,
  ) async {
    final collections =
        (await getAllCollectionsUseCase.singleOutput(none)).collections;

    return MoveDocumentToCollectionManager._(
      listenCollectionsUseCase,
      moveBookmarkUseCase,
      removeBookmarkUseCase,
      getBookmarkUseCase,
      isBookmarkedUseCase,
      createBookmarkUseCase,
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
    final isBookmarked = await _isBookmarkedUseCase.singleOutput(bookmarkId);
    if (!isBookmarked) return;
    final bookmark = await _getBookmarkUseCase.singleOutput(bookmarkId);
    final selectedCollection = _collections.firstWhere(
      (it) => it.id == bookmark.collectionId,
    );
    updateSelectedCollection(selectedCollection);
  }

  void updateSelectedCollection(Collection? collection) =>
      scheduleComputeState(() => _selectedCollection = collection);

  Future<void> onApplyPressed({required Document document}) async {
    final hasSelected = state.selectedCollection != null;
    final isBookmarked =
        await _isBookmarkedUseCase.singleOutput(document.documentUniqueId);
    if (!isBookmarked && hasSelected) {
      await _createBookmarkInSelectedCollection(document: document);
    }
    if (isBookmarked && !hasSelected) {
      await _removeBookmarkUseCase.call(document.documentUniqueId);
    }
    if (isBookmarked && hasSelected) {
      await _moveBookmarkToSelectedCollection(
          bookmarkId: document.documentUniqueId);
    }
  }

  Future<void> _moveBookmarkToSelectedCollection(
      {required UniqueId bookmarkId}) async {
    final param = MoveBookmarkUseCaseIn(
      bookmarkId: bookmarkId,
      collectionId: state.selectedCollection!.id,
    );
    await _moveBookmarkUseCase.call(param);
  }

  Future<void> _createBookmarkInSelectedCollection(
      {required Document document}) async {
    final param = CreateBookmarkFromDocumentUseCaseIn(
      document: document,
      collectionId: state.selectedCollection!.id,
    );
    await _createBookmarkUseCase.call(param);
  }

  @override
  Future<MoveDocumentToCollectionState?> computeState() async =>
      fold(_collectionsHandler).foldAll((usecaseOut, errorReport) {
        if (errorReport.isNotEmpty) {
          final error = errorReport.of(_collectionsHandler)!.error;
          logger.e(error);
          return state.copyWith(errorMsg: error.toString());
        }

        if (usecaseOut != null) {
          _collections = usecaseOut.collections;
        }

        final newState = state.copyWith(
          collections: _collections,
          selectedCollection: _selectedCollection,
        );

        return newState;
      });
}
