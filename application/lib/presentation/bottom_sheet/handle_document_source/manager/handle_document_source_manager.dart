import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_document_feedback_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class HandleDocumentSourceManager extends Cubit<MoveToCollectionState>
    with
        UseCaseBlocHelper<MoveToCollectionState>,
        ChangeUserReactionMixin<MoveToCollectionState> {
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final MoveBookmarkUseCase _moveBookmarkUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  final CreateBookmarkFromDocumentUseCase _createBookmarkUseCase;
  final GetBookmarkUseCase _getBookmarkUseCase;

  late final List<Collection> _collections;
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler;

  late final UseCaseSink<CreateBookmarkFromDocumentUseCaseIn, Bookmark>
      _createBookmarkHandler;
  late final UseCaseSink<UniqueId, Bookmark> _removeBookmarkHandler;
  late final UseCaseSink<MoveBookmarkUseCaseIn, Bookmark> _moveBookmarkHandler;

  UniqueId? _selectedCollectionId;
  bool _isBookmarked = false;

  MoveToCollectionManager._(
    this._listenCollectionsUseCase,
    this._moveBookmarkUseCase,
    this._removeBookmarkUseCase,
    this._getBookmarkUseCase,
    this._createBookmarkUseCase,
    this._collections,
  ) : super(MoveToCollectionState.initial()) {
    _init();
  }

  @factoryMethod
  static Future<MoveToCollectionManager> create(
    GetAllCollectionsUseCase getAllCollectionsUseCase,
    ListenCollectionsUseCase listenCollectionsUseCase,
    MoveBookmarkUseCase moveBookmarkUseCase,
    RemoveBookmarkUseCase removeBookmarkUseCase,
    GetBookmarkUseCase getBookmarkUseCase,
    CreateBookmarkFromDocumentUseCase createBookmarkUseCase,
  ) async {
    final collections =
        (await getAllCollectionsUseCase.singleOutput(none)).collections;

    return MoveToCollectionManager._(
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
    _createBookmarkHandler = pipe(_createBookmarkUseCase);
    _moveBookmarkHandler = pipe(_moveBookmarkUseCase);
    _removeBookmarkHandler = pipe(_removeBookmarkUseCase);
  }

  Future<void> updateInitialSelectedCollection({
    required UniqueId bookmarkId,
    UniqueId? initialSelectedCollectionId,
  }) async {
    late Bookmark bookmark;

    try {
      bookmark = await _getBookmarkUseCase.singleOutput(bookmarkId);
    } catch (_) {
      updateSelectedCollection(initialSelectedCollectionId);
      return;
    }

    final selectedCollection = _collections.firstWhere(
      (it) => it.id == bookmark.collectionId,
    );

    scheduleComputeState(() {
      _isBookmarked = true;
      _selectedCollectionId =
          initialSelectedCollectionId ?? selectedCollection.id;
    });
  }

  void updateSelectedCollection(UniqueId? collectionId) =>
      scheduleComputeState(() => _selectedCollectionId = collectionId);

  void onApplyToDocumentPressed({
    required Document document,
    DocumentProvider? provider,
  }) {
    final hasSelected = state.selectedCollectionId != null;
    final isBookmarked = state.isBookmarked;
    if (!isBookmarked && hasSelected) {
      final param = CreateBookmarkFromDocumentUseCaseIn(
        document: document,
        provider: provider,
        collectionId: state.selectedCollectionId!,
      );
      _createBookmarkHandler(param);
      changeUserReaction(
        document: document,
        userReaction: UserReaction.positive,
        context: FeedbackContext.implicit,
      );
    }
    if (isBookmarked && !hasSelected) {
      _removeBookmarkHandler(document.documentUniqueId);
    }
    if (isBookmarked && hasSelected) {
      _moveBookmark(bookmarkId: document.documentUniqueId);
    }
  }

  void onApplyToBookmarkPressed({required UniqueId bookmarkId}) {
    if (state.selectedCollectionId == null) {
      _removeBookmarkHandler(bookmarkId);
    } else {
      _moveBookmark(bookmarkId: bookmarkId);
    }
  }

  void _moveBookmark({required UniqueId bookmarkId}) {
    final param = MoveBookmarkUseCaseIn(
      bookmarkId: bookmarkId,
      collectionId: state.selectedCollectionId!,
    );
    _moveBookmarkHandler(param);
  }

  @override
  Future<MoveToCollectionState?> computeState() async => fold4(
        _collectionsHandler,
        _createBookmarkHandler,
        _moveBookmarkHandler,
        _removeBookmarkHandler,
      ).foldAll((
        collectionHandlerOut,
        createBookmarkOut,
        moveBookmarkOut,
        removeBookmarkOut,
        errorReport,
      ) {
        if (errorReport.isNotEmpty) {
          final report = errorReport.of(_collectionsHandler) ??
              errorReport.of(_createBookmarkHandler) ??
              errorReport.of(_moveBookmarkHandler) ??
              errorReport.of(_removeBookmarkHandler);
          logger.e(report!.error);
          return state.copyWith(errorObj: report.error);
        }

        if (collectionHandlerOut != null) {
          _collections = collectionHandlerOut.collections;
        }

        final _shouldClose = createBookmarkOut != null ||
            moveBookmarkOut != null ||
            removeBookmarkOut != null;

        final newState = MoveToCollectionState.populated(
          collections: _collections,
          selectedCollectionId: _selectedCollectionId,
          isBookmarked: _isBookmarked,
          shouldClose: _shouldClose,
        );

        return newState;
      });
}
