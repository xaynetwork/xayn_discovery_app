import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_outputs.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/presentation/bookmark/util/bookmark_errors_enum_mapper.dart';

import 'bookmarks_screen_state.dart';

@injectable
class BookmarksScreenManager extends Cubit<BookmarksScreenState>
    with UseCaseBlocHelper<BookmarksScreenState> {
  final ListenBookmarksUseCase _listenBookmarksUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  final MoveBookmarkUseCase _moveBookmarkUseCase;
  final BookmarkErrorsEnumMapper _bookmarkErrorsEnumMapper;
  final DateTimeHandler _dateTimeHandler;
  BookmarksScreenManager(
    this._listenBookmarksUseCase,
    this._removeBookmarkUseCase,
    this._moveBookmarkUseCase,
    this._bookmarkErrorsEnumMapper,
    this._dateTimeHandler,
  ) : super(
          BookmarksScreenState.initial(),
        ) {
    _init();
  }

  late final UseCaseSink<ListenBookmarksUseCaseIn, BookmarkUseCaseListOut>
      _listenBookmarksHandler;

  String? _useCaseError;

  void _init() {
    _listenBookmarksHandler = pipe(_listenBookmarksUseCase);
  }

  void enteringScreen(UniqueId collectionId) {
    _listenBookmarksHandler(
        ListenBookmarksUseCaseIn(collectionId: collectionId));
  }

  void moveBookmark({
    required UniqueId bookmarkId,
    required UniqueId collectionId,
  }) async {
    _useCaseError = null;
    final param = MoveBookmarkUseCaseIn(
        bookmarkId: bookmarkId, collectionId: collectionId);
    final useCaseOut = await _moveBookmarkUseCase.singleOutput(param);
    useCaseOut.mapOrNull(
      failure: (useCaseOut) => scheduleComputeState(
        () => _useCaseError =
            _bookmarkErrorsEnumMapper.mapEnumToString(useCaseOut.error),
      ),
    );
  }

  void removeBookmark(UniqueId bookmarkId) async {
    _useCaseError = null;
    final useCaseOut = await _removeBookmarkUseCase.singleOutput(bookmarkId);
    useCaseOut.mapOrNull(
      failure: (useCaseOut) => scheduleComputeState(
        () => _useCaseError =
            _bookmarkErrorsEnumMapper.mapEnumToString(useCaseOut.error),
      ),
    );
  }

  @override
  Future<BookmarksScreenState?> computeState() async =>
      fold(_listenBookmarksHandler).foldAll(
        (bookmarkEvent, errorReport) {
          String errorMsg;

          if (_useCaseError != null) {
            return state.copyWith(errorMsg: _useCaseError);
          }

          if (errorReport.exists(_listenBookmarksHandler)) {
            final error = errorReport.of(_listenBookmarksHandler)!.error;

            errorMsg = error.toString();

            return state.copyWith(
              errorMsg: errorMsg,
            );
          }

          if (bookmarkEvent != null) {
            List<Bookmark> bookmarks = [];
            bookmarkEvent.whenOrNull(success: (out) => bookmarks = out);
            return BookmarksScreenState.populated(
              bookmarks,
              _dateTimeHandler.getDateTimeNow(),
            );
          }
        },
      );
}
