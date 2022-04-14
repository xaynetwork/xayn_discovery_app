import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/engine_exception_raised_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/next_search_batch_request_failed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/restore_search_failed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/update_card_index_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/listen_reader_mode_settings_use_case.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/base_discovery_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/search_mixin.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

typedef OnSearchRequestSucceeded = Set<Document> Function(
    SearchRequestSucceeded event);
typedef OnRestoreSearchSucceeded = Set<Document> Function(
    RestoreSearchSucceeded event);
typedef OnNextSearchBatchRequestSucceeded = Set<Document> Function(
    NextSearchBatchRequestSucceeded event);
typedef OnNextSearchBatchRequestFailed = Set<Document> Function(
    NextSearchBatchRequestFailed event);
typedef OnRestoreSearchFailed = Set<Document> Function(
    RestoreSearchFailed event);

abstract class ActiveSearchNavActions {
  void onHomeNavPressed();

  void onPersonalAreaNavPressed();

  void onCardDetailsPressed(DiscoveryCardStandaloneArgs args);

  void onTrialExpired();
}

/// Manages the state for the active search screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
@injectable
class ActiveSearchManager extends BaseDiscoveryManager
    with SearchMixin<DiscoveryState>, OverlayManagerMixin<DiscoveryState>
    implements ActiveSearchNavActions {
  ActiveSearchManager(
    this._activeSearchNavActions,
    EngineEventsUseCase engineEventsUseCase,
    FetchCardIndexUseCase fetchCardIndexUseCase,
    UpdateCardIndexUseCase updateCardIndexUseCase,
    SendAnalyticsUseCase sendAnalyticsUseCase,
    CrudExplicitDocumentFeedbackUseCase crudExplicitDocumentFeedbackUseCase,
    HapticFeedbackMediumUseCase hapticFeedbackMediumUseCase,
    GetSubscriptionStatusUseCase getSubscriptionStatusUseCase,
    ListenReaderModeSettingsUseCase listenReaderModeSettingsUseCase,
    FeatureManager featureManager,
  ) : super(
          FeedType.search,
          engineEventsUseCase,
          _foldEngineEvent(),
          fetchCardIndexUseCase,
          updateCardIndexUseCase,
          sendAnalyticsUseCase,
          crudExplicitDocumentFeedbackUseCase,
          hapticFeedbackMediumUseCase,
          getSubscriptionStatusUseCase,
          listenReaderModeSettingsUseCase,
          featureManager,
        );

  final ActiveSearchNavActions _activeSearchNavActions;
  bool _isLoading = true;
  bool _didReachEnd = false;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get didReachEnd => _didReachEnd;

  void handleSearchTerm(String searchTerm) => scheduleComputeState(() {
        final trimmed = searchTerm.trim();

        if (trimmed.isEmpty) {
          return showOverlay(OverlayData.tooltipInvalidSearch());
        }

        _isLoading = true;
        _didReachEnd = false;
        resetCardIndex();

        search(searchTerm);
      });

  @override
  void resetParameters() {
    resetCardIndex();
    // clears the current pending observation, if any...
    observeDocument();
    // clear the inner-stored current observation...
    resetObservedDocument();
  }

  @override
  void onPersonalAreaNavPressed() =>
      _activeSearchNavActions.onPersonalAreaNavPressed();

  @override
  void onHomeNavPressed() => _activeSearchNavActions.onHomeNavPressed();

  void onSearchNavPressed() {
    // TODO probably go to the top of the feed
  }

  @override
  void onCardDetailsPressed(DiscoveryCardStandaloneArgs args) =>
      _activeSearchNavActions.onCardDetailsPressed(args);

  @override
  void onTrialExpired() => _activeSearchNavActions.onTrialExpired();

  @override
  void handleLoadMore() {
    if (_didReachEnd) return;

    requestNextSearchBatch();
  }

  /// A higher-order Function, which tracks the last event passed in,
  /// and ultimately runs the inner fold Function when the incoming event
  /// no longer matches lastEvent.
  static Set<Document> Function(EngineEvent?) Function(BaseDiscoveryManager)
      _foldEngineEvent() {
    // because foldEngineEvent runs within a combineLatest setup,
    // we can use lastEvent to compare with the incoming event,
    // if they are the same, then the fold does not need to re-run.
    // this is important, because _isLoading would otherwise falsely be
    // switched to true.
    EngineEvent? lastEvent;
    var lastResults = const <Document>{};

    return (BaseDiscoveryManager manager) {
      final self = manager as ActiveSearchManager;

      foldEngineEvent({
        required OnSearchRequestSucceeded searchRequestSucceeded,
        required OnRestoreSearchSucceeded restoreSearchSucceeded,
        required OnNextSearchBatchRequestSucceeded
            nextSearchBatchRequestSucceeded,
        required OnDocumentsUpdated documentsUpdated,
        required OnEngineExceptionRaised engineExceptionRaised,
        required OnNextSearchBatchRequestFailed nextSearchBatchRequestFailed,
        required OnRestoreSearchFailed restoreSearchFailed,
        required OnNonMatchedEngineEvent orElse,
      }) =>
          (EngineEvent? event) {
            if (event == lastEvent) return lastResults;

            lastEvent = event;

            if (event is SearchRequestSucceeded) {
              self._isLoading = false;
              self._didReachEnd =
                  event.items.length < AppDiscoveryEngine.searchPageSize;
              lastResults = searchRequestSucceeded(event);
            } else if (event is RestoreSearchSucceeded) {
              self._isLoading = false;
              lastResults = restoreSearchSucceeded(event);
            } else if (event is NextSearchBatchRequestSucceeded) {
              self._isLoading = false;
              self._didReachEnd = event.items.isEmpty;
              lastResults = nextSearchBatchRequestSucceeded(event);
            } else if (event is DocumentsUpdated) {
              lastResults = documentsUpdated(event);
            } else if (event is EngineExceptionRaised) {
              lastResults = engineExceptionRaised(event);
            } else if (event is NextSearchBatchRequestFailed) {
              self._didReachEnd = false;
              lastResults = nextSearchBatchRequestFailed(event);
            } else if (event is RestoreSearchFailed) {
              self._isLoading = false;
              lastResults = restoreSearchFailed(event);
            } else {
              lastResults = orElse();
            }

            return lastResults;
          };

      return foldEngineEvent(
        searchRequestSucceeded: (event) => event.items.toSet(),
        restoreSearchSucceeded: (event) => event.items.toSet(),
        nextSearchBatchRequestSucceeded: (event) =>
            {...lastResults, ...event.items},
        documentsUpdated: (event) => lastResults
            .map(
              (it) => event.items.firstWhere(
                (item) => item.documentId == it.documentId,
                orElse: () => it,
              ),
            )
            .toSet(),
        engineExceptionRaised: (event) {
          manager.sendAnalyticsUseCase(
            EngineExceptionRaisedEvent(
              event: event,
              feedType: FeedType.search,
            ),
          );

          logger.e('$event');

          return lastResults;
        },
        nextSearchBatchRequestFailed: (event) {
          manager.sendAnalyticsUseCase(
            NextSearchBatchRequestFailedEvent(
              event: event,
            ),
          );

          logger.e('$event');

          return lastResults;
        },
        restoreSearchFailed: (event) {
          manager.sendAnalyticsUseCase(
            RestoreSearchFailedEvent(
              event: event,
            ),
          );

          logger.e('$event');

          return lastResults;
        },
        orElse: () => lastResults,
      );
    };
  }

  @override
  void handleShowPaywallIfNeeded(SubscriptionStatus subscriptionStatus) {
    if (subscriptionStatus.subscriptionType == SubscriptionType.notSubscribed) {
      _activeSearchNavActions.onTrialExpired();
    }
  }
}
