import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
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

    final numberOfSessions = map[AppSettingsFields.numberOfSessions] as int?;
    final appVersion =
        _mapToAppVersionMapper.map(map[AppSettingsFields.appVersion]);

    return AppStatus(
      numberOfSessions: numberOfSessions ?? 0,
      lastKnownAppVersion: appVersion,
    );
  }

  @override
  DbEntityMap toMap(AppStatus entity) => {
        AppSettingsFields.numberOfSessions: entity.numberOfSessions,
        AppSettingsFields.appVersion:
            _appVersionToMapMapper.map(entity.lastKnownAppVersion),
      };
}

abstract class AppSettingsFields {
  AppSettingsFields._();

  static const int numberOfSessions = 0;
  static const int appVersion = 1;
}
