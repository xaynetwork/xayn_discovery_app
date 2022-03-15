import 'package:xayn_discovery_app/domain/model/app_status.dart';

const freeTrialDuration = Duration(days: 7);

extension AppStatusExtension on AppStatus {
  DateTime get trialEndDate => firstAppLaunchDate.add(freeTrialDuration);
}
