import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'app_status.freezed.dart';

const freeTrialDuration = Duration(days: 7);

@freezed
class AppStatus extends DbEntity with _$AppStatus {
  factory AppStatus._({
    required int numberOfSessions,
    required AppVersion lastKnownAppVersion,
    required DateTime trialEndDate,
    required UniqueId id,
  }) = _AppStatus;

  factory AppStatus({
    required int numberOfSessions,
    required AppVersion lastKnownAppVersion,
    required DateTime trialEndDate,
  }) =>
      AppStatus._(
        numberOfSessions: numberOfSessions,
        lastKnownAppVersion: lastKnownAppVersion,
        trialEndDate: trialEndDate,
        id: AppStatus.globalId,
      );

  factory AppStatus.initial() => AppStatus._(
        numberOfSessions: 0,
        lastKnownAppVersion: AppVersion.initial(),
        trialEndDate: DateTime.now().add(freeTrialDuration),
        id: AppStatus.globalId,
      );

  static UniqueId globalId = const UniqueId.fromTrustedString('app_status_id');
}
