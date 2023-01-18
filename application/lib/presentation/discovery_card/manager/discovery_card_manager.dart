import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/legacy/user_reaction.dart';
import 'package:xayn_discovery_app/domain/model/remote_content/processed_document.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_is_bookmarked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/gibberish_detection_usecase.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/inject_reader_meta_data_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/load_html_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/readability_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/mixin/collection_manager_flow_mixin.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_document_feedback_mixin.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/foreground/foreground_painter.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

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
        ErrorHandlingManagerMixin<DiscoveryCardState>,
        CollectionManagerFlowMixin<DiscoveryCardState>
    implements DiscoveryCardNavActions {
  final LoadHtmlUseCase _loadHtmlUseCase;
  final ReadabilityUseCase _readabilityUseCase;
  final InjectReaderMetaDataUseCase _injectReaderMetaDataUseCase;
  final GibberishDetectionUseCase _gibberishDetectionUseCase;
  final ListenIsBookmarkedUseCase _listenIsBookmarkedUseCase;
  final DiscoveryCardNavActions _discoveryCardNavActions;
  final CrudExplicitDocumentFeedbackUseCase
      _crudExplicitDocumentFeedbackUseCase;
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
        .followedBy(_injectReaderMetaDataUseCase)
        .followedBy(_gibberishDetectionUseCase),
  );
  late final UseCaseSink<UniqueId, BookmarkStatus> _isBookmarkedHandler =
      pipe(_listenIsBookmarkedUseCase);
  late final _crudExplicitDocumentFeedbackHandler =
      pipe(_crudExplicitDocumentFeedbackUseCase);

  bool _isLoading = false;
  Uri? _lastUpdatedDocument;

  DiscoveryCardManager(
    this._loadHtmlUseCase,
    this._readabilityUseCase,
    this._injectReaderMetaDataUseCase,
    this._discoveryCardNavActions,
    this._listenIsBookmarkedUseCase,
    this._crudExplicitDocumentFeedbackUseCase,
    this._hapticFeedbackMediumUseCase,
    this._gibberishDetectionUseCase,
  ) : super(DiscoveryCardState.initial());

  void updateDocument(Document document) {
    _isBookmarkedHandler(
        Bookmark.generateUniqueIdFromUri(document.resource.url));
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
    changeUserReaction(
      document: document,
      userReaction: userReaction,
      context: FeedbackContext.explicit,
      feedType: feedType,
    );
  }

  void shareDocument({
    required Document document,
    required FeedType? feedType,
  }) async {
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
    final didTap = Completer();
    showOverlay(
      OverlayData.tooltipBookmarked(
        document: document,
        onTap: () {
          didTap.complete();
          onBookmarkLongPressed(
            document,
            feedType: feedType,
          );
        },
        onClosed: () {},
      ),
      when: (oS, nS) =>
          oS?.bookmarkStatus != BookmarkStatus.bookmarked &&
          nS.bookmarkStatus == BookmarkStatus.bookmarked,
    );
    final isBookmarked = state.bookmarkStatus == BookmarkStatus.bookmarked;

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
    FeedType? feedType,
  ) {
    changeUserReaction(
      document: document,
      userReaction: UserReaction.positive,
      context: FeedbackContext.implicit,
      feedType: feedType,
    );
    openExternalUrl(url: document.resource.url.toString(), feedType: feedType);
  }

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);

  @override
  Future<DiscoveryCardState?> computeState() async => fold3(
        _updateUri,
        _isBookmarkedHandler,
        _crudExplicitDocumentFeedbackHandler,
      ).foldAll((
        processedDocument,
        bookmarkStatus,
        explicitDocumentFeedback,
        errorReport,
      ) {
        if (errorReport.isNotEmpty) {
          final report = errorReport.of(_updateUri) ??
              errorReport.of(_isBookmarkedHandler);
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
          arcVariation: state.arcVariation == ArcVariation.v0
              ? getRandomArcVariation()
              : state.arcVariation,
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

        final document = nextState.processedDocument;
        if (document != null) {
          nextState = nextState.copyWith(
            textIsReadable: document.detectedLanguage != null &&
                    document.isGibberish == null ||
                document.isGibberish == false,
          );
        }

        return nextState;
      });

  @override
  void onBackNavPressed() => _discoveryCardNavActions.onBackNavPressed();

  void onBookmarkLongPressed(
    Document document, {
    FeedType? feedType,
  }) {
    startBookmarkDocumentFlow(
      document,
      feedType: feedType,
      provider: state.processedDocument?.getProvider(document.resource),
    );
  }
}
