import 'package:xayn_discovery_app/domain/model/push_notifications/push_notifications_conditions_status.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';

const int _kNumOfSessionsThreshold = 2;
const int _kNumOfScrollsThreshold = 4;

extension PushNotificationsConditionsStatusExtension
    on PushNotificationsConditionsStatus {
  static PushNotificationsConditionsStatus performStatusCheck({
    required int numberOfSessions,
    required UserInteractions userInteractions,
  }) {
    // The conditions are listed in the description of the following story
    // https://xainag.atlassian.net/browse/TB-4088
    final reached = numberOfSessions >= _kNumOfSessionsThreshold &&
        userInteractions.numberOfScrollsPerSession >= _kNumOfScrollsThreshold;
    return reached
        ? PushNotificationsConditionsStatus.reached
        : PushNotificationsConditionsStatus.notReached;
  }
}
