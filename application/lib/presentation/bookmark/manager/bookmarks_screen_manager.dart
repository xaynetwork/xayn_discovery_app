import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_exception.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';

import 'bookmarks_screen_state.dart';

@injectable
class BookmarksScreenManager extends Cubit<BookmarksScreenState>
    with UseCaseBlocHelper<BookmarksScreenState> {
  final GetAllBookmarksUseCase _getAllBookmarksUseCase;
  final ListenBookmarksUseCase _listenBookmarksUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  final MoveBookmarkUseCase _moveBookmarkUseCase;
  final DateTimeHandler _dateTimeHandler;
  BookmarksScreenManager(
    this._getAllBookmarksUseCase,
    this._listenBookmarksUseCase,
    this._removeBookmarkUseCase,
    this._moveBookmarkUseCase,
    this._dateTimeHandler,
  ) : super(
          BookmarksScreenState.initial(),
        ) {
    _init();
  }

  late final UseCaseSink<UniqueId, ListenBookmarksUseCaseOut>
      _listenBookmarksHandler;

  List<Bookmark> _bookmarks = [];
  dynamic _useCaseError;

  void _init() {
    _listenBookmarksHandler = pipe(_listenBookmarksUseCase);
  }

  Future<void> enteringScreen(UniqueId collectionId) async {
    scheduleComputeState(
      () async {
        final useCaseResult = await _callGetBookmarksUseCase(collectionId);
        _bookmarks =
            useCaseResult != null ? useCaseResult.bookmarks : _bookmarks;
        _listenBookmarksHandler(collectionId);
      },
    );
  }

  Future<void> updateBookmarksList(UniqueId? collectionId) async {
    final useCaseResult = await _callGetBookmarksUseCase(collectionId);
    if (useCaseResult != null) {
      scheduleComputeState(
        () => _bookmarks = useCaseResult.bookmarks,
      );
    }
  }

  Future<GetAllBookmarksUseCaseOut?> _callGetBookmarksUseCase(
    UniqueId? collectionId,
  ) async {
    _useCaseError = null;
    final useCaseResult = await _getAllBookmarksUseCase
        .singleOutput(GetAllBookmarksUseCaseIn(
      collectionId: collectionId,
    ))
        .catchError((e, _) {
      scheduleComputeState(() => _useCaseError = e);
      return null;
    });
    return useCaseResult;
  }

  void moveBookmark({
    required UniqueId bookmarkId,
    required UniqueId collectionId,
  }) {
    _useCaseError = null;
    final param = MoveBookmarkUseCaseParam(
        bookmarkId: bookmarkId, collectionId: collectionId);
    _moveBookmarkUseCase.singleOutput(param).catchError((e, _) {
      scheduleComputeState(() => _useCaseError = e);
      return null;
    });
  }

  void removeBookmark(UniqueId bookmarkId) {
    _useCaseError = null;
    _removeBookmarkUseCase.singleOutput(bookmarkId).catchError((e, _) {
      scheduleComputeState(() => _useCaseError = e);
      return null;
    });
  }

  @override
  Future<BookmarksScreenState?> computeState() async {
    String errorMsg;
    if (_useCaseError != null) {
      final error = _useCaseError;
      if (error is BookmarkUseCaseException) {
        errorMsg = error.msg;
      } else {
        errorMsg = error.toString();
      }
      return state.copyWith(errorMsg: errorMsg);
    }

    return fold(_listenBookmarksHandler).foldAll((usecaseOut, errorReport) {
      if (errorReport.exists(_listenBookmarksHandler)) {
        final error = errorReport.of(_listenBookmarksHandler)!.error;

        errorMsg = error.toString();

        return state.copyWith(
          errorMsg: errorMsg,
        );
      }
      final newTimestamp = _dateTimeHandler.getDateTimeNow();
      if (usecaseOut != null) {
        _bookmarks = usecaseOut.bookmarks;
      }
      return BookmarksScreenState.populated(
        _bookmarks,
        newTimestamp,
      );
    });
  }
}
