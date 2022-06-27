import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/cta_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/onboarding_status_mapper.dart';

@singleton
class AppStatusMapper extends BaseDbEntityMapper<AppStatus> {
  final MapToAppVersionMapper _mapToAppVersionMapper;
  final AppVersionToMapMapper _appVersionToMapMapper;
  final OnboardingStatusToDbEntityMapMapper _onboardingStatusToMapMapper;
  final DbEntityMapToOnboardingStatusMapper _mapToOnboardingStatusMapper;
  final CTAMapToDbEntityMapper _ctaMapToDbEntityMapper;
  final DbEntityMapToCTAMapper _mapToCTAMapper;

  const AppStatusMapper(
    this._mapToAppVersionMapper,
    this._appVersionToMapMapper,
    this._onboardingStatusToMapMapper,
    this._mapToOnboardingStatusMapper,
    this._ctaMapToDbEntityMapper,
    this._mapToCTAMapper,
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
    final onboardingStatus =
        _mapToOnboardingStatusMapper.map(map[AppStatusFields.onboardingStatus]);
    final ratingDialogAlreadyVisible =
        map[AppStatusFields.ratingDialogAlreadyVisible] as bool?;
    final isBetaUser = map[AppStatusFields.isBetaUser] as bool?;
    final cta = _mapToCTAMapper.map(map[AppStatusFields.cta]);
    final extraTrialDate = map[AppStatusFields.extraTrialDate] as DateTime?;

    return AppStatus(
      numberOfSessions: numberOfSessions ?? 0,
      lastKnownAppVersion: appVersion,
      firstAppLaunchDate: firstAppLaunchDate ?? DateTime.now(),
      extraTrialEndDate: extraTrialDate,
      lastSeenDate: lastSeenDate ?? DateTime.now(),
      userId: UniqueId.fromTrustedString(userId ?? const Uuid().v4()),
      onboardingStatus: onboardingStatus,
      ratingDialogAlreadyVisible: ratingDialogAlreadyVisible ?? false,
      isBetaUser: isBetaUser ?? false,
      cta: cta,
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
        AppStatusFields.onboardingStatus:
            _onboardingStatusToMapMapper.map(entity.onboardingStatus),
        AppStatusFields.ratingDialogAlreadyVisible:
            entity.ratingDialogAlreadyVisible,
        AppStatusFields.isBetaUser: entity.isBetaUser,
        AppStatusFields.cta: _ctaMapToDbEntityMapper.map(entity.cta),
        AppStatusFields.extraTrialDate: entity.extraTrialEndDate,
      };
}

abstract class AppStatusFields {
  AppStatusFields._();

  static const int numberOfSessions = 0;
  static const int appVersion = 1;
  static const int firstAppLaunchDate = 2;
  static const int userId = 3;
  static const int lastSeenDate = 4;
  static const int onboardingStatus = 5;
  static const int ratingDialogAlreadyVisible = 6;
  static const int isBetaUser = 7;
  static const int cta = 8;
  static const int extraTrialDate = 9;
}
