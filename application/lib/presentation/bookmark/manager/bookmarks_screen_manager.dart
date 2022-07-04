import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/bookmark_deleted_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/mark_onboarding_type_completed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/need_to_show_onboarding_use_case.dart';
import 'package:xayn_discovery_app/presentation/bookmark/util/bookmark_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/mixin/collection_manager_flow_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';

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
    with
        UseCaseBlocHelper<BookmarksScreenState>,
        OverlayManagerMixin<BookmarksScreenState>,
        CollectionManagerFlowMixin<BookmarksScreenState> {
  final ListenBookmarksUseCase _listenBookmarksUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  final BookmarkErrorsEnumMapper _bookmarkErrorsEnumMapper;
  final DateTimeHandler _dateTimeHandler;
  final BookmarksScreenNavActions _bookmarksScreenNavActions;
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;
  late final UniqueId? _collectionId;
  final NeedToShowOnboardingUseCase _needToShowOnboardingUseCase;
  final MarkOnboardingTypeCompletedUseCase _markOnboardingTypeCompletedUseCase;

  BookmarksScreenManager(
    this._listenBookmarksUseCase,
    this._removeBookmarkUseCase,
    this._hapticFeedbackMediumUseCase,
    this._bookmarkErrorsEnumMapper,
    this._dateTimeHandler,
    this._bookmarksScreenNavActions,
    this._needToShowOnboardingUseCase,
    this._markOnboardingTypeCompletedUseCase,
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

  void onDeleteSwipe(UniqueId bookmarkId) async {
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

  void onBackNavPressed() => _bookmarksScreenNavActions.onBackNavPressed();

  void onBookmarkPressed({
    required Bookmark bookmark,
  }) {
    _bookmarksScreenNavActions.onBookmarkPressed(
      bookmarkId: bookmark.documentId,
      isPrimary: true,
      feedType: null,
    );
  }

  void checkIfNeedToShowOnboarding() async {
    const type = OnboardingType.bookmarksManage;
    final show = await _needToShowOnboardingUseCase.singleOutput(type);
    if (!show) return;
    final data = OverlayData.bottomSheetOnboarding(type, () {
      _markOnboardingTypeCompletedUseCase.call(type);
    });
    showOverlay(data);
  }

  void onMoveSwipe(UniqueId bookmarkId) => startMoveBookmarkFlow(bookmarkId);

  void onBookmarkLongPressed({
    required UniqueId bookmarkId,
    required VoidCallback onClose,
  }) =>
      startBookmarkOptionsFlow(
        bookmarkId: bookmarkId,
        onClose: onClose,
      );
}
