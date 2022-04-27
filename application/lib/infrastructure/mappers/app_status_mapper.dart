import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/onboarding_status_mapper.dart';

@singleton
class AppStatusMapper extends BaseDbEntityMapper<AppStatus> {
  final MapToAppVersionMapper _mapToAppVersionMapper;
  final AppVersionToMapMapper _appVersionToMapMapper;
  final OnboardingStatusToDbEntityMapMapper _onboardingStatusToMapMapper;
  final DbEntityMapToOnboardingStatusMapper _mapToOnboardingStatusMapper;

  const AppStatusMapper(
    this._mapToAppVersionMapper,
    this._appVersionToMapMapper,
    this._onboardingStatusToMapMapper,
    this._mapToOnboardingStatusMapper,
  );

  @override
  AppStatus? fromMap(Map? map) {
    if (map == null) return null;

    final numberOfSessions = map[AppSettingsFields.numberOfSessions] as int?;
    final appVersion =
        _mapToAppVersionMapper.map(map[AppSettingsFields.appVersion]);
    final firstAppLaunchDate =
        map[AppSettingsFields.firstAppLaunchDate] as DateTime?;
    final lastSeenDate = map[AppSettingsFields.lastSeenDate] as DateTime?;
    final userId = map[AppSettingsFields.userId] as String?;
    final onboardingStatus = _mapToOnboardingStatusMapper
        .map(map[AppSettingsFields.onboardingStatus]);

    return AppStatus(
      numberOfSessions: numberOfSessions ?? 0,
      lastKnownAppVersion: appVersion,
      firstAppLaunchDate: firstAppLaunchDate ?? DateTime.now(),
      lastSeenDate: lastSeenDate ?? DateTime.now(),
      userId: UniqueId.fromTrustedString(userId ?? const Uuid().v4()),
      onboardingStatus: onboardingStatus,
    );
  }

  @override
  DbEntityMap toMap(AppStatus entity) => {
        AppSettingsFields.numberOfSessions: entity.numberOfSessions,
        AppSettingsFields.appVersion:
            _appVersionToMapMapper.map(entity.lastKnownAppVersion),
        AppSettingsFields.firstAppLaunchDate: entity.firstAppLaunchDate,
        AppSettingsFields.userId: entity.userId.value,
        AppSettingsFields.lastSeenDate: entity.lastSeenDate,
        AppSettingsFields.onboardingStatus:
            _onboardingStatusToMapMapper.map(entity.onboardingStatus),
      };
}

abstract class AppSettingsFields {
  AppSettingsFields._();

  static const int numberOfSessions = 0;
  static const int appVersion = 1;
  static const int firstAppLaunchDate = 2;
  static const int userId = 3;
  static const int lastSeenDate = 4;
  static const int onboardingStatus = 5;
}
