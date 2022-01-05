import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'app_status.freezed.dart';

@freezed
class AppStatus extends DbEntity with _$AppStatus {
  factory AppStatus._({
    required int numberOfSessions,
    required AppVersion lastKnownAppVersion,
    required UniqueId id,
  }) = _AppStatus;

  factory AppStatus({
    required int numberOfSessions,
    required AppVersion lastKnownAppVersion,
  }) =>
      AppStatus._(
        numberOfSessions: numberOfSessions,
        lastKnownAppVersion: lastKnownAppVersion,
        id: AppStatus.globalId,
      );

  factory AppStatus.initial() => AppStatus(
        numberOfSessions: 0,
        lastKnownAppVersion: AppVersion.initial(),
      );

  static UniqueId globalId = const UniqueId.fromTrustedString('app_status_id');
}
