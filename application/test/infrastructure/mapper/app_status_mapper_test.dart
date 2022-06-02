import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/cta/cta.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_status.dart';
import 'package:xayn_discovery_app/domain/model/survey_banner/survey_banner_data.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_status_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/cta_mapper.dart';

import '../../test_utils/utils.dart';

void main() {
  late AppStatusMapper mapper;

  late MockMapToAppVersionMapper mockMapToAppVersionMapper;
  late MockAppVersionToMapMapper mockAppVersionToMapMapper;
  late MockOnboardingStatusToDbEntityMapMapper mockOnboardingToMapMapper;
  late MockDbEntityMapToOnboardingStatusMapper mockMapToOnboardingMapper;
  late MockSurveyBannerDataMapper mockSurveyBannerDataMapper;
  late MockDbEntityMapToSurveyBannerDataMapper
      mockDbEntityMapToSurveyBannerDataMapper;
  late CTAMapToDbEntityMapper ctaMapToDbEntityMapper;
  late DbEntityMapToCTAMapper dbEntityMapToCTAMapper;
  late final now = DateTime.now();
  late final lastSeen = now.subtract(const Duration(minutes: 1));

  const numberOfSessions = 10;
  const userIdValue = 'userId';
  const onboardingMap = {
    0: 'hi there',
  };
  const onboardingValue = OnboardingStatus.initial();
  final appVersionMap = {
    0: 'hi there',
  };
  final appVersionValue = AppVersion.initial();

  const surveyBannerDataMap = {
    0: 0,
    1: false,
  };

  const surveyBannerDataValue = SurveyBannerData.initial();

  const ctaValue = CTA(surveyBannerData: surveyBannerDataValue);

  const ctaMap = {
    0: surveyBannerDataMap,
  };

  setUp(() async {
    mockMapToAppVersionMapper = MockMapToAppVersionMapper();
    mockAppVersionToMapMapper = MockAppVersionToMapMapper();
    mockOnboardingToMapMapper = MockOnboardingStatusToDbEntityMapMapper();
    mockMapToOnboardingMapper = MockDbEntityMapToOnboardingStatusMapper();
    mockSurveyBannerDataMapper = MockSurveyBannerDataMapper();
    mockDbEntityMapToSurveyBannerDataMapper =
        MockDbEntityMapToSurveyBannerDataMapper();

    ctaMapToDbEntityMapper = CTAMapToDbEntityMapper(
      mockSurveyBannerDataMapper,
    );

    dbEntityMapToCTAMapper =
        DbEntityMapToCTAMapper(mockDbEntityMapToSurveyBannerDataMapper);

    mapper = AppStatusMapper(
      mockMapToAppVersionMapper,
      mockAppVersionToMapMapper,
      mockOnboardingToMapMapper,
      mockMapToOnboardingMapper,
      ctaMapToDbEntityMapper,
      dbEntityMapToCTAMapper,
    );
  });

  group('AppSettingsMapper tests: ', () {
    test('fromMap', () {
      when(mockMapToAppVersionMapper.map(appVersionMap))
          .thenReturn(appVersionValue);
      when(mockMapToOnboardingMapper.map(onboardingMap))
          .thenReturn(onboardingValue);
      when(mockDbEntityMapToSurveyBannerDataMapper.map(surveyBannerDataMap))
          .thenReturn(surveyBannerDataValue);

      final map = {
        AppStatusFields.numberOfSessions: numberOfSessions,
        AppStatusFields.appVersion: appVersionMap,
        AppStatusFields.firstAppLaunchDate: now,
        AppStatusFields.userId: userIdValue,
        AppStatusFields.lastSeenDate: lastSeen,
        AppStatusFields.onboardingStatus: onboardingMap,
        AppStatusFields.isBetaUser: false,
        AppStatusFields.cta: ctaMap,
      };
      final appStatus = mapper.fromMap(map);
      expect(
        appStatus,
        AppStatus(
          numberOfSessions: numberOfSessions,
          lastKnownAppVersion: appVersionValue,
          firstAppLaunchDate: now,
          userId: const UniqueId.fromTrustedString(userIdValue),
          lastSeenDate: lastSeen,
          onboardingStatus: const OnboardingStatus.initial(),
          ratingDialogAlreadyVisible: false,
          isBetaUser: false,
          cta: ctaValue,
        ),
      );
    });

    test('toMap', () {
      when(mockAppVersionToMapMapper.map(appVersionValue))
          .thenReturn(appVersionMap);
      when(mockOnboardingToMapMapper.map(onboardingValue))
          .thenReturn(onboardingMap);
      when(mockSurveyBannerDataMapper.map(surveyBannerDataValue))
          .thenReturn(surveyBannerDataMap);

      final appStatus = AppStatus(
        numberOfSessions: numberOfSessions,
        lastKnownAppVersion: appVersionValue,
        firstAppLaunchDate: now,
        userId: const UniqueId.fromTrustedString(userIdValue),
        lastSeenDate: lastSeen,
        onboardingStatus: onboardingValue,
        ratingDialogAlreadyVisible: false,
        isBetaUser: true,
        cta: ctaValue,
      );

      final map = mapper.toMap(appStatus);
      final expectedMap = {
        AppStatusFields.numberOfSessions: numberOfSessions,
        AppStatusFields.appVersion: appVersionMap,
        AppStatusFields.firstAppLaunchDate: now,
        AppStatusFields.userId: userIdValue,
        AppStatusFields.lastSeenDate: lastSeen,
        AppStatusFields.onboardingStatus: onboardingMap,
        AppStatusFields.ratingDialogAlreadyVisible: false,
        AppStatusFields.isBetaUser: true,
        AppStatusFields.cta: ctaMap,
      };
      expect(map, expectedMap);
    });
  });
}
