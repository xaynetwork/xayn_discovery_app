import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'app_status.freezed.dart';

@freezed
class AppStatus extends DbEntity with _$AppStatus {
  static const freeTrialDuration = Duration(days: 7);

  factory AppStatus._({
    required int numberOfSessions,
    required AppVersion lastKnownAppVersion,
    required DateTime trialEndDate,
    required UniqueId id,
    required UniqueId userId,
  }) = _AppStatus;

  factory AppStatus({
    required int numberOfSessions,
    required AppVersion lastKnownAppVersion,
    required DateTime trialEndDate,
    required UniqueId userId,
  }) =>
      AppStatus._(
        numberOfSessions: numberOfSessions,
        lastKnownAppVersion: lastKnownAppVersion,
        trialEndDate: trialEndDate,
        id: AppStatus.globalId,
        userId: userId,
      );

  factory AppStatus.initial() => AppStatus._(
        numberOfSessions: 0,
        lastKnownAppVersion: AppVersion.initial(),
        trialEndDate: DateTime.now().add(freeTrialDuration),
        id: AppStatus.globalId,
        userId: UniqueId(),
      );

  static UniqueId globalId = const UniqueId.fromTrustedString('app_status_id');
}
