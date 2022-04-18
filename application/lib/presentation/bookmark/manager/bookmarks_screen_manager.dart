import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/bookmark_deleted_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/presentation/bookmark/util/bookmark_errors_enum_mapper.dart';

import 'bookmarks_screen_state.dart';

abstract class BookmarksScreenNavActions {
  void onBackNavPressed();

  void onBookmarkPressed({
    required bool isPrimary,
    required UniqueId bookmarkId,
    FeedType? feedType,
  });
}

@injectable
class BookmarksScreenManager extends Cubit<BookmarksScreenState>
    with UseCaseBlocHelper<BookmarksScreenState>
    implements BookmarksScreenNavActions {
  final ListenBookmarksUseCase _listenBookmarksUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  final BookmarkErrorsEnumMapper _bookmarkErrorsEnumMapper;
  final DateTimeHandler _dateTimeHandler;
  final BookmarksScreenNavActions _bookmarksScreenNavActions;
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;
  late final UniqueId? _collectionId;

  BookmarksScreenManager(
    this._listenBookmarksUseCase,
    this._removeBookmarkUseCase,
    this._hapticFeedbackMediumUseCase,
    this._bookmarkErrorsEnumMapper,
    this._dateTimeHandler,
    this._bookmarksScreenNavActions,
    this._sendAnalyticsUseCase, {

    /// Required param to load a collection when entering a screen, alternatively call [enteringScreen]
    @factoryParam UniqueId? collectionId,
  })  : _collectionId = collectionId,
        super(
          BookmarksScreenState.initial(),
        ) {
    _init();
    final collectionId = _collectionId;
    if (collectionId != null) {
      enteringScreen(collectionId);
    }
  }

  late final UseCaseSink<ListenBookmarksUseCaseIn, ListenBookmarksUseCaseOut>
      _listenBookmarksHandler;

  String? _useCaseError;

  void _init() {
    _listenBookmarksHandler = pipe(_listenBookmarksUseCase);
  }

  void enteringScreen(UniqueId collectionId) {
    _fechCollection(collectionId);
  }

  void _fechCollection(UniqueId collectionId) {
    _listenBookmarksHandler(
        ListenBookmarksUseCaseIn(collectionId: collectionId));
  }

  void removeBookmark(UniqueId bookmarkId) async {
    _useCaseError = null;
    final useCaseOut = await _removeBookmarkUseCase.call(bookmarkId);
    useCaseOut.last.fold(
      defaultOnError: _defaultOnError,
      matchOnError: {
        On<BookmarkUseCaseError>(_matchOnBookmarkUseCaseError),
      },
      onValue: (bookmark) {
        _sendAnalyticsUseCase(
          BookmarkDeletedEvent(
            fromDefaultCollection:
                bookmark.collectionId == Collection.readLaterId,
          ),
        );
      },
    );
  }

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);

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
            return BookmarksScreenState.populated(
              bookmarkEvent.bookmarks,
              _dateTimeHandler.getDateTimeNow(),
              bookmarkEvent.collectionName,
            );
          }
        },
      );

  void _defaultOnError(Object e, StackTrace? s) =>
      scheduleComputeState(() => _useCaseError = e.toString());

  void _matchOnBookmarkUseCaseError(Object e, StackTrace? s) =>
      scheduleComputeState(
        () => _useCaseError = _bookmarkErrorsEnumMapper.mapEnumToString(
          e as BookmarkUseCaseError,
        ),
      );

  @override
  void onBackNavPressed() => _bookmarksScreenNavActions.onBackNavPressed();

  @override
  void onBookmarkPressed({
    required bool isPrimary,
    required UniqueId bookmarkId,
    FeedType? feedType,
  }) =>
      _bookmarksScreenNavActions.onBookmarkPressed(
        bookmarkId: bookmarkId,
        isPrimary: true,
        feedType: feedType,
      );
}
