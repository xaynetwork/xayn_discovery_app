import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/are_local_notifications_allowed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/get_push_notifications_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

const int _kNumberOfTimesShownThreshold = 1;

@injectable
class CanDisplayPushNotificationsCardUseCase extends UseCase<None, bool> {
  final GetPushNotificationsStatusUseCase _getPushNotificationsStatusUseCase;
  final AreLocalNotificationsAllowedUseCase
      _areLocalNotificationsAllowedUseCase;
  final AppStatusRepository _appStatusRepository;
  final FeatureManager _featureManager;

  CanDisplayPushNotificationsCardUseCase(
    this._getPushNotificationsStatusUseCase,
    this._areLocalNotificationsAllowedUseCase,
    this._appStatusRepository,
    this._featureManager,
  );

  @override
  Stream<bool> transaction(None param) async* {
    final localNotificationsAllowed =
        await _areLocalNotificationsAllowedUseCase.singleOutput(none);
    if (localNotificationsAllowed ||
        !_featureManager.areRemoteNotificationsEnabled) {
      yield false;
      return;
    }

    final userDidChangePushNotifications =
        await _getPushNotificationsStatusUseCase.singleOutput(none);
    final appStatus = _appStatusRepository.appStatus;
    final numberOfTimesShown =
        appStatus.cta.pushNotifications.numberOfTimesShown;
    final canBeShown = numberOfTimesShown < _kNumberOfTimesShownThreshold;
    yield userDidChangePushNotifications == false && canBeShown;
  }
}
