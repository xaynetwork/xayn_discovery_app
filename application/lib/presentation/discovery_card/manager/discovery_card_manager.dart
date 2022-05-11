import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/remote_content/processed_document.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_bookmarked_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_shared_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_is_bookmarked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/toggle_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/crud_document_filter_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/inject_reader_meta_data_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/load_html_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/readability_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_document_feedback_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

typedef UriHandler = void Function(Uri uri);

// todo: must come from settings!
const String _kReadingTimeLanguage = 'en-US';

/// The state manager of a [DiscoveryCard] widget.
///
/// Currently has 2 goals:
/// - provide the html reader mode elements for the story-mode display
/// - provide the color palette of the card's background image
@injectable
class DiscoveryCardManager extends Cubit<DiscoveryCardState>
    with
        UseCaseBlocHelper<DiscoveryCardState>,
        ChangeUserReactionMixin<DiscoveryCardState>,
        OpenExternalUrlMixin<DiscoveryCardState>,
        OverlayManagerMixin<DiscoveryCardState>,
        ErrorHandlingManagerMixin<DiscoveryCardState>
    implements DiscoveryCardNavActions {
  final LoadHtmlUseCase _loadHtmlUseCase;
  final ReadabilityUseCase _readabilityUseCase;
  final InjectReaderMetaDataUseCase _injectReaderMetaDataUseCase;
  final ShareUriUseCase _shareUriUseCase;
  final ListenIsBookmarkedUseCase _listenIsBookmarkedUseCase;
  final DiscoveryCardNavActions _discoveryCardNavActions;
  final ToggleBookmarkUseCase _toggleBookmarkUseCase;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;
  final CrudExplicitDocumentFeedbackUseCase
      _crudExplicitDocumentFeedbackUseCase;
  final CrudDocumentFilterUseCase _crudDocumentFilterUseCase;
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;

  /// html reader mode elements:
  ///
  /// - loads the source html
  ///   * emits a loading state while the source html is loading
  /// - transforms the loaded html into reader mode html
  /// - extracts lists of html elements from the html tree, to display in story mode
  late final UseCaseSink<Uri, ProcessedDocument> _updateUri =
      pipe(_loadHtmlUseCase).transform(
    (out) => out
        .scheduleComputeState(
          consumeEvent: (it) => !it.isCompleted,
          run: (it) => _isLoading = !it.isCompleted,
        )
        .map(
          (it) => ReadabilityConfig(
            uri: it.uri,
            html: it.html,
            disableJsonLd: true,
            classesToPreserve: const [],
          ),
        )
        .followedBy(_readabilityUseCase)
        .map(
          (it) => ReadingTimeInput(
            processHtmlResult: it,
            lang: _kReadingTimeLanguage,
            singleUnit: R.strings.readingTimeUnitSingular,
            pluralUnit: R.strings.readingTimeUnitPlural,
          ),
        )
        .followedBy(_injectReaderMetaDataUseCase),
  );
  late final UseCaseSink<UniqueId, BookmarkStatus> _isBookmarkedHandler =
      pipe(_listenIsBookmarkedUseCase);
  late final UseCaseSink<CreateBookmarkFromDocumentUseCaseIn, AnalyticsEvent>
      _toggleBookmarkHandler = pipe(_toggleBookmarkUseCase).transform(
    (out) => out
        .map(
          (it) => DocumentBookmarkedEvent(
            document: it.document,
            isBookmarked: it.isBookmarked,
            toDefaultCollection: true,
            feedType: it.feedType,
          ),
        )
        .cast<AnalyticsEvent>()
        .followedBy(_sendAnalyticsUseCase),
  )..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  late final _crudExplicitDocumentFeedbackHandler =
      pipe(_crudExplicitDocumentFeedbackUseCase);

  bool _isLoading = false;
  Uri? _lastUpdatedDocument;

  DiscoveryCardManager(
    this._loadHtmlUseCase,
    this._readabilityUseCase,
    this._injectReaderMetaDataUseCase,
    this._shareUriUseCase,
    this._discoveryCardNavActions,
    this._listenIsBookmarkedUseCase,
    this._toggleBookmarkUseCase,
    this._sendAnalyticsUseCase,
    this._crudExplicitDocumentFeedbackUseCase,
    this._hapticFeedbackMediumUseCase,
    this._crudDocumentFilterUseCase,
  ) : super(DiscoveryCardState.initial());

  void updateDocument(Document document) {
    _isBookmarkedHandler(document.documentUniqueId);
    _crudExplicitDocumentFeedbackHandler(
      DbCrudIn.watch(
        document.documentId.uniqueId,
      ),
    );

    // ideally, url is nullable, but we don't control this
    if (document.resource.url == Uri.base ||
        document.resource.url == _lastUpdatedDocument) return;

    /// Update the uri which contains the news article
    _lastUpdatedDocument = document.resource.url;
    _updateUri(document.resource.url);
  }

  void onFeedback({
    required Document document,
    required UserReaction userReaction,
    required FeedType? feedType,
  }) async {
    final url = document.resource.sourceDomain.value;
    final filter = DocumentFilter.fromSource(url);
    final op = DbCrudIn.get(filter.id);
    final res = await _crudDocumentFilterUseCase.singleOutput(op);

    if (res.mapOrNull(single: (s) => s.value) == null) {
      showOverlay(
        OverlayData.tooltipDocumentFilter(onTap: () {
          showOverlay(OverlayData.bottomSheetDocumentFilter(document));
        }),
        when: (_, nS) => nS.explicitDocumentUserReaction.isIrrelevant,
      );
    }

    changeUserReaction(
      document: document,
      userReaction: userReaction,
      context: FeedbackContext.explicit,
      feedType: feedType,
    );
  }

  void shareUri({
    required Document document,
    required FeedType? feedType,
  }) {
    _shareUriUseCase.call(document.resource.url);

    _sendAnalyticsUseCase(DocumentSharedEvent(
      document: document,
      feedType: feedType,
    ));

    changeUserReaction(
      document: document,
      userReaction: UserReaction.positive,
      context: FeedbackContext.implicit,
      feedType: feedType,
    );
  }

  void toggleBookmarkDocument(
    Document document, {
    FeedType? feedType,
  }) {
    showOverlay(
      OverlayData.tooltipBookmarked(
          document: document,
          onTap: () {
            showOverlay(OverlayData.bottomSheetMoveDocumentToCollection(
              document: document,
              provider: state.processedDocument?.getProvider(document.resource),
              feedType: feedType,
            ));
          }),
      when: (oS, nS) =>
          oS?.bookmarkStatus != BookmarkStatus.bookmarked &&
          nS.bookmarkStatus == BookmarkStatus.bookmarked,
    );
    final isBookmarked = state.bookmarkStatus == BookmarkStatus.bookmarked;

    _toggleBookmarkHandler(
      CreateBookmarkFromDocumentUseCaseIn(
        document: document,
        provider: state.processedDocument?.getProvider(document.resource),
        feedType: feedType,
      ),
    );

    if (!isBookmarked) {
      changeUserReaction(
        document: document,
        userReaction: UserReaction.positive,
        context: FeedbackContext.implicit,
        feedType: feedType,
      );
    }
  }

  void openWebResourceUrl(
    Document document,
    CurrentView currentView,
    FeedType? feedType,
  ) {
    changeUserReaction(
      document: document,
      userReaction: UserReaction.positive,
      context: FeedbackContext.implicit,
      feedType: feedType,
    );
    openExternalUrl(
        url: document.resource.url.toString(),
        currentView: currentView,
        feedType: feedType);
  }

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);

  @override
  Future<DiscoveryCardState?> computeState() async => fold4(
        _updateUri,
        _isBookmarkedHandler,
        _crudExplicitDocumentFeedbackHandler,
        _toggleBookmarkHandler,
      ).foldAll((
        processedDocument,
        bookmarkStatus,
        explicitDocumentFeedback,
        toggleBookmark,
        errorReport,
      ) {
        if (errorReport.isNotEmpty) {
          final report = errorReport.of(_updateUri) ??
              errorReport.of(_isBookmarkedHandler) ??
              errorReport.of(_toggleBookmarkHandler);
          if (report != null) {
            logger.e(report.error);
            handleError(report.error);
            return DiscoveryCardState.error();
          }
        }

        var nextState = DiscoveryCardState(
          isComplete: !_isLoading,
        );

        nextState = nextState.copyWith(
          bookmarkStatus: bookmarkStatus ?? BookmarkStatus.unknown,
        );

        if (processedDocument != null) {
          nextState = nextState.copyWith(
            processedDocument: processedDocument,
          );
        }

        final reaction =
            explicitDocumentFeedback?.mapOrNull(single: (v) => v.value);
        if (reaction != null) {
          nextState = nextState.copyWith(
            explicitDocumentUserReaction: reaction.userReaction,
          );
        }

        return nextState;
      });

  @override
  void onBackNavPressed() => _discoveryCardNavActions.onBackNavPressed();

  void onBookmarkLongPressed(
    Document document, {
    FeedType? feedType,
  }) =>
      showOverlay(
        OverlayData.bottomSheetMoveDocumentToCollection(
          document: document,
          provider: state.processedDocument?.getProvider(document.resource),
          feedType: feedType,
        ),
      );
}
