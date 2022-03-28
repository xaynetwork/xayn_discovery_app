import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_subscription_window_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';

abstract class PersonalAreaNavActions {
  void onHomeNavPressed();

  void onActiveSearchNavPressed();

  void onCollectionsNavPressed();

  void onHomeFeedSettingsNavPressed();

  void onSettingsNavPressed();
}

@lazySingleton
class PersonalAreaManager extends Cubit<PersonalAreaState>
    with
        UseCaseBlocHelper<PersonalAreaState>,
        OpenExternalUrlMixin<PersonalAreaState>
    implements PersonalAreaNavActions {
  final PersonalAreaNavActions _navActions;
  final FeatureManager _featureManager;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final ListenSubscriptionStatusUseCase _listenSubscriptionStatusUseCase;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;

  PersonalAreaManager(
    this._navActions,
    this._featureManager,
    this._getSubscriptionStatusUseCase,
    this._listenSubscriptionStatusUseCase,
    this._sendAnalyticsUseCase,
  ) : super(PersonalAreaState.initial()) {
    _init();
  }

  bool _initDone = false;
  late final UseCaseValueStream<SubscriptionStatus> _subscriptionStatusHandler;
  late SubscriptionStatus _subscriptionStatus;

  void _init() async {
    scheduleComputeState(() async {
      // read values
      _subscriptionStatus = await _getSubscriptionStatusUseCase
          .singleOutput(PurchasableIds.subscription);

      // attach listeners
      _subscriptionStatusHandler = consume(
        _listenSubscriptionStatusUseCase,
        initialData: PurchasableIds.subscription,
      );

      _initDone = true;
    });
  }

  void onTrialBannerTapped() {
    _sendAnalyticsUseCase(
      OpenSubscriptionWindowEvent(
        currentView: SubscriptionWindowCurrentView.personalArea,
      ),
    );
  }

  @override
  Future<PersonalAreaState?> computeState() async {
    if (!_initDone) return null;
    PersonalAreaState buildReady() => PersonalAreaState(
          isPaymentEnabled: _featureManager.isPaymentEnabled,
          subscriptionStatus: _subscriptionStatus,
        );
    return fold(_subscriptionStatusHandler)
        .foldAll((subscriptionStatus, _) async {
      if (subscriptionStatus != null) {
        _subscriptionStatus = subscriptionStatus;
      }

      return buildReady();
    });
  }

  @override
  void onHomeNavPressed() => _navActions.onHomeNavPressed();

  @override
  void onActiveSearchNavPressed() => _navActions.onActiveSearchNavPressed();

  @override
  void onCollectionsNavPressed() => _navActions.onCollectionsNavPressed();

  @override
  void onHomeFeedSettingsNavPressed() =>
      _navActions.onHomeFeedSettingsNavPressed();

  @override
  void onSettingsNavPressed() => _navActions.onSettingsNavPressed();
}
