import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/extensions/push_notifications_conditions_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/push_notifications/push_notifications_conditions_status.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/can_display_push_notifications_card_use_case.dart';

@injectable
class GetPushNotificationsConditionsStatusUseCase
    extends UseCase<None, PushNotificationsConditionsStatus> {
  final UserInteractionsRepository userInteractionsRepository;
  final AppStatusRepository appStatusRepository;
  final CanDisplayPushNotificationsCardUseCase canDisplayPushNotificationsCard;

  GetPushNotificationsConditionsStatusUseCase(
    this.userInteractionsRepository,
    this.appStatusRepository,
    this.canDisplayPushNotificationsCard,
  );

  @override
  Stream<PushNotificationsConditionsStatus> transaction(None param) async* {
    final canDisplay = await canDisplayPushNotificationsCard.singleOutput(none);
    if (!canDisplay) {
      yield PushNotificationsConditionsStatus.notReached;
      return;
    }

    final numberOfSessions = appStatusRepository.appStatus.numberOfSessions;
    final userInteractions = userInteractionsRepository.userInteractions;

    yield PushNotificationsConditionsStatusExtension.performStatusCheck(
      numberOfSessions: numberOfSessions,
      userInteractions: userInteractions,
    );
  }
}
