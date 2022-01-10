import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/engine_events_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/observe_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/temp/request_feed_mixin.dart';
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
        RequestFeedMixin<DiscoveryFeedState>,
        ObserveDocumentMixin<DiscoveryFeedState>
    implements DiscoveryFeedNavActions {
  DiscoveryFeedManager(
    this._engine,
    this._discoveryFeedNavActions,
  ) : super(DiscoveryFeedState.empty());

  final DiscoveryEngine _engine;
  final DiscoveryFeedNavActions _discoveryFeedNavActions;

  final ObservedViewTypes _observedViewTypes = {};
  Document? _observedDocument;
  int _documentIndex = 0;
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
    final document = _observedDocument = state.results.elementAt(index);

    observeDocument(
      document: document,
      mode: _observedViewTypes[document],
    );

    scheduleComputeState(() => _documentIndex = index);
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

  @override
  Future<DiscoveryFeedState?> computeState() async => fold(
        engineEvents,
      ).foldAll((
        engineEvent,
        errorReport,
      ) {
        final engine = _engine as AppDiscoveryEngine;
        var results = engineEvent is FeedRequestSucceeded
            ? {...state.results, ...engineEvent.items}
            : state.results;
        final changeDocumentFeedbackParams = engineEvent != null
            ? engine.resolveChangeDocumentFeedbackParameters(engineEvent)
            : null;

        if (changeDocumentFeedbackParams != null) {
          results = results
              .map(
                (it) => it.documentId == changeDocumentFeedbackParams.documentId
                    ? it.copyWith(
                        feedback: changeDocumentFeedbackParams.feedback)
                    : it,
              )
              .toSet();
        }

        final nextState = DiscoveryFeedState(
          results: results,
          isComplete: !isLoading,
          isInErrorState: errorReport.isNotEmpty,
          isFullScreen: _isFullScreen,
          resultIndex: _documentIndex,
        );

        // guard against same-state emission
        if (!nextState.equals(state)) return nextState;
      });

  @override
  void onSearchNavPressed() => _discoveryFeedNavActions.onSearchNavPressed();

  @override
  void onAccountNavPressed() => _discoveryFeedNavActions.onAccountNavPressed();

  void onHomeNavPressed() {
    // TODO probably go to the top of the feed
  }
}
