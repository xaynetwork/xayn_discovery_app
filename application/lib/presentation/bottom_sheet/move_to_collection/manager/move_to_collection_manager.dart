import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/bookmark_moved_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/bottom_sheet_dismissed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_bookmarked_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_document_feedback_mixin.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class MoveToCollectionManager extends Cubit<MoveToCollectionState>
    with
        UseCaseBlocHelper<MoveToCollectionState>,
        ChangeUserReactionMixin<MoveToCollectionState>,
        OverlayManagerMixin<MoveToCollectionState>,
        ErrorHandlingManagerMixin<MoveToCollectionState> {
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final MoveBookmarkUseCase _moveBookmarkUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  final CreateBookmarkFromDocumentUseCase _createBookmarkUseCase;
  final GetBookmarkUseCase _getBookmarkUseCase;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;

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
    this._sendAnalyticsUseCase,
  ) : super(MoveToCollectionState.initial()) {
    _init();
  }

  @factoryMethod
  static MoveToCollectionManager create(
    CollectionsRepository collectionsRepository,
    ListenCollectionsUseCase listenCollectionsUseCase,
    MoveBookmarkUseCase moveBookmarkUseCase,
    RemoveBookmarkUseCase removeBookmarkUseCase,
    GetBookmarkUseCase getBookmarkUseCase,
    CreateBookmarkFromDocumentUseCase createBookmarkUseCase,
    SendAnalyticsUseCase sendAnalyticsUseCase,
  ) {
    final collections = collectionsRepository.getAll();
    return MoveToCollectionManager._(
      listenCollectionsUseCase,
      moveBookmarkUseCase,
      removeBookmarkUseCase,
      getBookmarkUseCase,
      createBookmarkUseCase,
      collections,
      sendAnalyticsUseCase,
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
    FeedType? feedType,
    DocumentProvider? provider,
  }) {
    final hasSelected = state.selectedCollectionId != null;
    final isBookmarked = state.isBookmarked;
    if (!isBookmarked && hasSelected) {
      final param = CreateBookmarkFromDocumentUseCaseIn(
        document: document,
        provider: provider,
        collectionId: state.selectedCollectionId!,
        feedType: feedType,
      );
      _createBookmarkHandler(param);
      changeUserReaction(
        document: document,
        userReaction: UserReaction.positive,
        context: FeedbackContext.implicit,
        feedType: feedType,
      );
      _sendAnalyticsUseCase(
        DocumentBookmarkedEvent(
          document: document,
          isBookmarked: true,
          toDefaultCollection:
              state.selectedCollectionId == Collection.readLaterId,
          feedType: feedType,
        ),
      );
    }
    if (isBookmarked && !hasSelected) {
      _removeBookmarkHandler(
        Bookmark.generateUniqueIdFromUri(document.resource.url),
      );
      _sendAnalyticsUseCase(
        DocumentBookmarkedEvent(
          document: document,
          isBookmarked: false,
          toDefaultCollection: false,
          feedType: feedType,
        ),
      );
    }
    if (isBookmarked && hasSelected) {
      _moveBookmark(
          bookmarkId: Bookmark.generateUniqueIdFromUri(document.resource.url));
    }
  }

  void onApplyToBookmarkPressed({required UniqueId bookmarkId}) {
    if (state.selectedCollectionId == null) {
      _removeBookmarkHandler(bookmarkId);
    } else {
      _moveBookmark(bookmarkId: bookmarkId);
    }
  }

  void onCancelPressed({required Duration screenDuration}) {
    _sendAnalyticsUseCase(
      BottomSheetDismissedEvent(
        bottomSheetView: BottomSheetView.saveToCollection,
        duration: screenDuration,
      ),
    );
  }

  void _moveBookmark({required UniqueId bookmarkId}) {
    final param = MoveBookmarkUseCaseIn(
      bookmarkId: bookmarkId,
      collectionId: state.selectedCollectionId!,
    );
    _moveBookmarkHandler(param);
    _sendAnalyticsUseCase(
      BookmarkMovedEvent(
        toDefaultCollection:
            state.selectedCollectionId == Collection.readLaterId,
      ),
    );
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
          handleError(report.error);
          return state;
        }

        if (collectionHandlerOut != null) {
          _collections = collectionHandlerOut.collections;
        }

        final shouldClose = createBookmarkOut != null ||
            moveBookmarkOut != null ||
            removeBookmarkOut != null;

        final newState = MoveToCollectionState.populated(
          collections: _collections,
          selectedCollectionId: _selectedCollectionId,
          isBookmarked: _isBookmarked,
          shouldClose: shouldClose,
        );

        return newState;
      });
}
