import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/remote_content/processed_document.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_document_feedback_mixin.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_is_bookmarked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/inject_reader_meta_data_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/load_html_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/readability_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
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
        ChangeDocumentFeedbackMixin<DiscoveryCardState> {
  final ConnectivityUriUseCase _connectivityUseCase;
  final LoadHtmlUseCase _loadHtmlUseCase;
  final ReadabilityUseCase _readabilityUseCase;
  final InjectReaderMetaDataUseCase _injectReaderMetaDataUseCase;
  final ListenIsBookmarkedUseCase _listenIsBookmarkedUseCase;
  final ShareUriUseCase _shareUriUseCase;
  final CreateBookmarkFromDocumentUseCase _createBookmarkUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;

  late final UseCaseSink<Uri, ProcessedDocument> _updateUri;
  late final UseCaseSink<UniqueId, bool> _isBookmarkedHandler;

  bool _isLoading = false;

  DiscoveryCardManager(
    this._connectivityUseCase,
    this._loadHtmlUseCase,
    this._readabilityUseCase,
    this._injectReaderMetaDataUseCase,
    this._shareUriUseCase,
    this._listenIsBookmarkedUseCase,
    this._createBookmarkUseCase,
    this._removeBookmarkUseCase,
  ) : super(DiscoveryCardState.initial()) {
    _init();
  }

  void updateDocument(Document document) async {
    _isBookmarkedHandler(document.documentUniqueId);

    /// Update the uri which contains the news article
    _updateUri(document.webResource.url);
  }

  void shareUri(Uri uri) => _shareUriUseCase.call(uri);

  void toggleBookmarkDocument(Document document) => state.isBookmarked
      ? _removeBookmarkUseCase(document.documentUniqueId)
      : _createBookmarkUseCase.call(document);

  Future<void> _init() async {
    _isBookmarkedHandler = pipe(_listenIsBookmarkedUseCase);

    /// html reader mode elements:
    ///
    /// - loads the source html
    ///   * emits a loading state while the source html is loading
    /// - transforms the loaded html into reader mode html
    /// - extracts lists of html elements from the html tree, to display in story mode
    _updateUri = pipe(_connectivityUseCase).transform(
      (out) => out
          .distinct()
          .followedBy(_loadHtmlUseCase)
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
  }

  @override
  Future<DiscoveryCardState?> computeState() async =>
      fold2(_updateUri, _isBookmarkedHandler).foldAll((
        processedDocument,
        isBookmarked,
        errorReport,
      ) {
        if (errorReport.isNotEmpty) {
          final report = errorReport.of(_updateUri) ??
              errorReport.of(_isBookmarkedHandler);
          logger.e(report!.error);

          return DiscoveryCardState.error();
        }

        var nextState = state.copyWith(
          isComplete: !_isLoading,
        );

        if (isBookmarked != null) {
          nextState = nextState.copyWith(
            isBookmarked: isBookmarked,
          );
        }

        if (processedDocument != null) {
          nextState = nextState.copyWith(
            processedDocument: processedDocument,
          );
        }

        return nextState;
      });
}
