import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'app_status.freezed.dart';

@freezed
class AppStatus extends DbEntity with _$AppStatus {
  factory AppStatus._({
    required int numberOfSessions,
    required AppVersion appVersion,
    required UniqueId id,
  }) = _AppStatus;

  factory AppStatus.global({
    required int numberOfSessions,
    required AppVersion appVersion,
  }) =>
      AppStatus._(
        numberOfSessions: numberOfSessions,
        appVersion: appVersion,
        id: AppStatus.globalId,
      );

  factory AppStatus.initial() => AppStatus.global(
        numberOfSessions: 0,
        appVersion: AppVersion.initial(),
      );

  static UniqueId globalId = const UniqueId.fromTrustedString('app_status_id');
}
