import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/check_markets_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/request_feed_mixin.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/base_discovery_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// Manages the state for the main, or home discovery feed screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
@injectable
class DiscoveryFeedManager extends BaseDiscoveryManager
    with
        RequestFeedMixin<DiscoveryFeedState>,
        CheckMarketsMixin<DiscoveryFeedState>
    implements DiscoveryFeedNavActions {
  DiscoveryFeedManager(
    this._discoveryFeedNavActions,
    FetchCardIndexUseCase fetchCardIndexUseCase,
    UpdateCardIndexUseCase updateCardIndexUseCase,
    SendAnalyticsUseCase sendAnalyticsUseCase,
    CrudExplicitDocumentFeedbackUseCase crudExplicitDocumentFeedbackUseCase,
  ) : super(
          fetchCardIndexUseCase,
          updateCardIndexUseCase,
          sendAnalyticsUseCase,
          crudExplicitDocumentFeedbackUseCase,
        );

  final DiscoveryFeedNavActions _discoveryFeedNavActions;

  bool _didChangeMarkets = false;

  /// Triggers the discovery engine to load more results.
  void handleLoadMore() => requestNextFeedBatch();

  void handleCheckMarkets() => checkMarkets();

  /// Configuration will change, after this method completes.
  @override
  void willChangeMarkets() => scheduleComputeState(() {
        resetCardIndex();
        _didChangeMarkets = true;

        // clears the current pending observation, if any...
        observeDocument();
        // clear the inner-stored current observation...
        resetObservedDocument();
        // closes the current feed...
        closeFeedDocuments(state.results.map((it) => it.documentId).toSet());
      });

  /// Configuration was updated, we now ask for fresh documents, under the
  /// new market settings.
  @override
  void didChangeMarkets() => requestNextFeedBatch();

  @override
  void onSearchNavPressed() {
    // detect that we exit the feed screen
    handleActivityStatus(false);

    _discoveryFeedNavActions.onSearchNavPressed();
  }

  @override
  void onPersonalAreaNavPressed() {
    // detect that we exit the feed screen
    handleActivityStatus(false);

    _discoveryFeedNavActions.onPersonalAreaNavPressed();
  }

  @override
  Future<DiscoveryFeedState?> computeState() async {
    if (_didChangeMarkets) {
      _didChangeMarkets = false;

      return state.copyWith(results: const <Document>{});
    }

    return super.computeState();
  }
}
