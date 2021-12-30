import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/mixins/engine_events_mixin.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/mixins/observe_document_mixin.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/mixins/request_feed_mixin.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/listen_discovery_feed_axis_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

const int kBufferCount = 4;
const Duration kResolveCardAsSkippedDuration = Duration(seconds: 3);
Duration kBatchSkippedThreshold = kResolveCardAsSkippedDuration * kBufferCount;

typedef ObservedViewTypes = Map<Document, DocumentViewMode>;

/// Manages the state for the main, or home discovery feed screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
@injectable
class DiscoveryFeedManager extends Cubit<DiscoveryFeedState>
    with
        UseCaseBlocHelper<DiscoveryFeedState>,
        EngineEventsMixin<DiscoveryFeedState>,
        TempRequestFeedMixin<DiscoveryFeedState>,
        ObserveDocumentMixin<DiscoveryFeedState>
    implements DiscoveryFeedNavActions {
  DiscoveryFeedManager(
    this._listenDiscoveryFeedAxisUseCase,
    this._discoveryFeedNavActions,
  ) : super(DiscoveryFeedState.empty()) {
    _initHandlers();
  }

  final ListenDiscoveryFeedAxisUseCase _listenDiscoveryFeedAxisUseCase;
  final DiscoveryFeedNavActions _discoveryFeedNavActions;

  late final UseCaseValueStream<DiscoveryFeedAxis> _discoveryFeedAxisHandler;

  final ObservedViewTypes _observedViewTypes = {};
  Document? _observedDocument;
  bool _isFullScreen = false;

  void handleNavigateIntoCard() {
    scheduleComputeState(() => _isFullScreen = true);
  }

  void handleNavigateOutOfCard() {
    scheduleComputeState(() => _isFullScreen = false);
  }

  /// Trigger this handler whenever the primary card changes.
  /// The [index] correlates with the index of the current primary card.
  void handleIndexChanged(int index) {
    final document = _observedDocument = state.results?.elementAt(index);

    if (document != null) {
      observeDocument(
        document: document,
        mode: _observedViewTypes[document],
      );
    }
  }

  /// Triggers a new observation for [document], if that document matches
  /// the last known inner document (secondary cards may also trigger).
  /// Use [viewType] to indicate the current view of that same document.
  void handleViewType(Document document, DocumentViewMode mode) {
    _observedViewTypes[document] = mode;

    if (document == _observedDocument) {
      observeDocument(
        document: document,
        mode: mode,
      );
    }
  }

  /// Handles moving the app between foreground and background.
  ///
  /// When the app moves into the background
  /// - we stop observing the last known card
  ///
  /// When the app moves into the foreground
  /// - we trigger a new observation with the last known card details
  void handleActivityStatus(bool isAppInForeground) {
    observeDocument(
      document: isAppInForeground ? _observedDocument : null,
      mode: isAppInForeground ? _observedViewTypes[_observedDocument] : null,
    );
  }

  /// Triggers the fake discovery engine to load more results, using a random
  /// keyword which is derived from the current result set.
  void handleLoadMore() async {
    requestNextFeedBatch();
  }

  void _initHandlers() {
    _discoveryFeedAxisHandler = consume(
      _listenDiscoveryFeedAxisUseCase,
      initialData: none,
    );
  }

  @override
  Future<DiscoveryFeedState?> computeState() async => fold2(
        _discoveryFeedAxisHandler,
        engineEvents,
      ).foldAll((
        axis,
        engineEvent,
        errorReport,
      ) {
        if (errorReport.isNotEmpty) {
          return state.copyWith(
            isInErrorState: true,
          );
        }

        if (engineEvent is FeedRequestSucceeded) {
          final currentResults = state.results ?? const <Document>[];

          return state.copyWith(
            results: {...currentResults, ...engineEvent.items},
            isComplete: !isLoading,
            isFullScreen: _isFullScreen,
            isInErrorState: false,
            axis: axis ?? DiscoveryFeedAxis.vertical,
          );
        }
      });

  @override
  void onSearchNavPressed() => _discoveryFeedNavActions.onSearchNavPressed();

  @override
  void onAccountNavPressed() => _discoveryFeedNavActions.onAccountNavPressed();

  void onHomeNavPressed() {
    // TODO probably go to the top of the feed
  }
}
