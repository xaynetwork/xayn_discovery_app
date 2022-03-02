import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';

abstract class PersonalAreaNavActions {
  void onHomeNavPressed();

  void onActiveSearchNavPressed();

  void onCollectionsNavPressed();

  void onHomeFeedSettingsNavPressed();

  void onSettingsNavPressed();
}

@lazySingleton
class PersonalAreaManager extends Cubit<PersonalAreaState>
    with UseCaseBlocHelper<PersonalAreaState>
    implements PersonalAreaNavActions {
  final PersonalAreaNavActions _navActions;
  final FeatureManager _featureManager;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;

  PersonalAreaManager(
    this._navActions,
    this._featureManager,
    this._getSubscriptionStatusUseCase,
  ) : super(PersonalAreaState.initial()) {
    _init();
  }

  bool _initDone = false;

  late final SubscriptionStatus _subscriptionStatus;

  void _init() async {
    scheduleComputeState(() async {
      _subscriptionStatus = await _getSubscriptionStatusUseCase
          .singleOutput(PurchasableIds.subscription);

      _initDone = true;
    });
  }

  @override
  Future<PersonalAreaState?> computeState() async {
    if (!_initDone) return null;
    return PersonalAreaState(
      subscriptionStatus: _subscriptionStatus,
      isPaymentEnabled: _featureManager.isPaymentEnabled,
    );
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
