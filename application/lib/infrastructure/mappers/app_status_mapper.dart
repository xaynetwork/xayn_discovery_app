import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

@singleton
class AppStatusMapper extends BaseDbEntityMapper<AppStatus> {
  final MapToAppVersionMapper _mapToAppVersionMapper;
  final AppVersionToMapMapper _appVersionToMapMapper;

  const AppStatusMapper(
    this._mapToAppVersionMapper,
    this._appVersionToMapMapper,
  );

  @override
  AppStatus? fromMap(Map? map) {
    if (map == null) return null;

    final numberOfSessions = map[AppStatusFields.numberOfSessions] as int?;
    final appVersion =
        _mapToAppVersionMapper.map(map[AppStatusFields.appVersion]);
    final firstAppLaunchDate =
        map[AppStatusFields.firstAppLaunchDate] as DateTime?;
    final lastSeenDate = map[AppStatusFields.lastSeenDate] as DateTime?;
    final userId = map[AppStatusFields.userId] as String?;

    return AppStatus(
      numberOfSessions: numberOfSessions ?? 0,
      lastKnownAppVersion: appVersion,
      firstAppLaunchDate: firstAppLaunchDate ?? DateTime.now(),
      lastSeenDate: lastSeenDate ?? DateTime.now(),
      userId: UniqueId.fromTrustedString(userId ?? const Uuid().v4()),
    );
  }

  @override
  DbEntityMap toMap(AppStatus entity) => {
        AppStatusFields.numberOfSessions: entity.numberOfSessions,
        AppStatusFields.appVersion:
            _appVersionToMapMapper.map(entity.lastKnownAppVersion),
        AppStatusFields.firstAppLaunchDate: entity.firstAppLaunchDate,
        AppStatusFields.userId: entity.userId.value,
        AppStatusFields.lastSeenDate: entity.lastSeenDate,
      };
}

abstract class AppStatusFields {
  AppStatusFields._();

  static const int numberOfSessions = 0;
  static const int appVersion = 1;
  static const int firstAppLaunchDate = 2;
  static const int userId = 3;
  static const int lastSeenDate = 4;
}
