import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_bookmark_use_case.dart';
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

  late List<Collection> _collections;
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler;
  Collection? _selectedCollection;
  bool _isBookmarked = false;
  bool _shouldClose = false;
  Object? _error;

  MoveDocumentToCollectionManager._(
    this._listenCollectionsUseCase,
    this._moveBookmarkUseCase,
    this._removeBookmarkUseCase,
    this._getBookmarkUseCase,
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
  ) async {
    final collections =
        (await getAllCollectionsUseCase.singleOutput(none)).collections;

    return MoveDocumentToCollectionManager._(
      listenCollectionsUseCase,
      moveBookmarkUseCase,
      removeBookmarkUseCase,
      getBookmarkUseCase,
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
    late Bookmark bookmark;

    try {
      bookmark = await _getBookmarkUseCase.singleOutput(bookmarkId);
    } catch (_) {
      updateSelectedCollection(forceSelectCollection);
      return;
    }

    final selectedCollection = _collections.firstWhere(
      (it) => it.id == bookmark.collectionId,
    );

    scheduleComputeState(() {
      _isBookmarked = true;
      _selectedCollection = forceSelectCollection ?? selectedCollection;
    });
  }

  void updateSelectedCollection(Collection? collection) =>
      scheduleComputeState(() => _selectedCollection = collection);

  void onApplyPressed({required Document document}) {
    final hasSelected = state.selectedCollection != null;
    final isBookmarked = state.isBookmarked;
    if (!isBookmarked && hasSelected) {
      _createBookmarkInSelectedCollection(document: document);
    }
    if (isBookmarked && !hasSelected) {
      _removeBookmarkFromSelectedCollection(
          bookmarkId: document.documentUniqueId);
    }
    if (isBookmarked && hasSelected) {
      _moveBookmarkToSelectedCollection(bookmarkId: document.documentUniqueId);
    }
  }

  void _moveBookmarkToSelectedCollection({required UniqueId bookmarkId}) async {
    final param = MoveBookmarkUseCaseIn(
      bookmarkId: bookmarkId,
      collectionId: state.selectedCollection!.id,
    );
    final result = await _moveBookmarkUseCase(param);
    _handleError(result);
  }

  void _removeBookmarkFromSelectedCollection(
      {required UniqueId bookmarkId}) async {
    final result = await _removeBookmarkUseCase(bookmarkId);
    _handleError(result);
  }

  void _createBookmarkInSelectedCollection({required Document document}) async {
    final param = CreateBookmarkFromDocumentUseCaseIn(
      document: document,
      collectionId: state.selectedCollection!.id,
    );
    final result = await _createBookmarkUseCase(param);
    _handleError(result);
  }

  void _handleError(List<UseCaseResult> useCaseResults) {
    var hasError = false;
    useCaseResults.single.fold(
        defaultOnError: (error, _) {
          hasError = true;
          scheduleComputeState(() => _error = error);
        },
        onValue: (_) {});

    if (!hasError) scheduleComputeState(() => _shouldClose = true);
  }

  @override
  Future<MoveDocumentToCollectionState?> computeState() async =>
      fold(_collectionsHandler).foldAll((usecaseOut, errorReport) {
        if (errorReport.isNotEmpty) {
          final error = errorReport.of(_collectionsHandler)!.error;
          logger.e(error);
          return state.copyWith(errorObj: error);
        }

        if (_error != null) {
          final newState = state.copyWith(errorObj: _error);
          logger.e(_error);
          scheduleComputeState(() => _error = null);
          return newState;
        }

        if (usecaseOut != null) {
          _collections = usecaseOut.collections;
        }

        final newState = MoveDocumentToCollectionState.populated(
          collections: _collections,
          selectedCollection: _selectedCollection,
          isBookmarked: _isBookmarked,
          shouldClose: _shouldClose,
        );

        return newState;
      });
}
