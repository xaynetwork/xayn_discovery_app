import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/cta/cta.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'app_status.freezed.dart';

@freezed
class AppStatus extends DbEntity with _$AppStatus {
  factory AppStatus._({
    required int numberOfSessions,
    required DateTime lastSeenDate,
    required AppVersion lastKnownAppVersion,
    required DateTime firstAppLaunchDate,
    required UniqueId id,
    required UniqueId userId,
    required OnboardingStatus onboardingStatus,
    required bool ratingDialogAlreadyVisible,
    required bool isBetaUser,
    required CTA cta,
  }) = _AppStatus;

  factory AppStatus({
    required int numberOfSessions,
    required AppVersion lastKnownAppVersion,
    required DateTime lastSeenDate,
    required DateTime firstAppLaunchDate,
    required UniqueId userId,
    required OnboardingStatus onboardingStatus,
    required bool ratingDialogAlreadyVisible,
    required bool isBetaUser,
    required CTA cta,
  }) =>
      AppStatus._(
        numberOfSessions: numberOfSessions,
        lastSeenDate: lastSeenDate,
        lastKnownAppVersion: lastKnownAppVersion,
        firstAppLaunchDate: firstAppLaunchDate,
        id: AppStatus.globalId,
        userId: userId,
        onboardingStatus: onboardingStatus,
        ratingDialogAlreadyVisible: ratingDialogAlreadyVisible,
        isBetaUser: isBetaUser,
        cta: cta,
      );

  factory AppStatus.initial() => AppStatus._(
        numberOfSessions: 0,
        lastKnownAppVersion: AppVersion.initial(),
        firstAppLaunchDate: DateTime.now(),
        lastSeenDate: DateTime.now(),
        id: AppStatus.globalId,
        userId: UniqueId(),
        onboardingStatus: const OnboardingStatus.initial(),
        ratingDialogAlreadyVisible: false,
        isBetaUser: false,
        cta: const CTA.initial(),
      );

  static UniqueId globalId = const UniqueId.fromTrustedString('app_status_id');
}
