import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/cta/cta.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_status.dart';
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
  late MockInLineCardMapper mockInLineCardMapper;
  late MockDbEntityMapToSurveyInLineCardMapper
      mockDbEntityMapToSurveyBannerMapper;
  late MockDbEntityMapToCountrySelectionInLineCardMapper
      mockDbEntityMapToCountrySelectionInLineCardMapper;
  late MockDbEntityMapToSourceSelectionInLineCardMapper
      mockDbEntityMapToSourceSelectionInLineCardMapper;
  late MockDbEntityMapToPushNotificationsInLineCardMapper
      mockDbEntityMapToPushNotificationsInLineCardMapper;
  late MockDbEntityMapToTopicsInLineCardMapper
      mockDbEntityMapToTopicsInLineCardMapper;
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

  const surveyBannerMap = {
    0: 0,
    1: false,
    2: 2,
  };

  const sourceSelectionMap = {
    0: 2,
    1: true,
    2: 5,
  };

  const countrySelectionMap = {
    0: 1,
    1: false,
    2: 3,
  };

  const pushNotificationsMap = {
    0: 2,
    1: false,
    2: 1,
  };

  const topicsMap = {
    0: 2,
    1: true,
    2: 5,
  };

  const surveyBannerValue = InLineCard(
    cardType: CardType.survey,
    lastSessionNumberWhenShown: 2,
    hasBeenClicked: false,
    numberOfTimesShown: 0,
  );
  const countrySelectionValue = InLineCard(
    cardType: CardType.countrySelection,
    lastSessionNumberWhenShown: 3,
    hasBeenClicked: false,
    numberOfTimesShown: 1,
  );
  const sourceSelectionValue = InLineCard(
    cardType: CardType.sourceSelection,
    lastSessionNumberWhenShown: 5,
    hasBeenClicked: true,
    numberOfTimesShown: 2,
  );
  const pushNotificationsValue = InLineCard(
    cardType: CardType.sourceSelection,
    lastSessionNumberWhenShown: 2,
    hasBeenClicked: false,
    numberOfTimesShown: 1,
  );
  const topicsValue = InLineCard(
    cardType: CardType.topics,
    lastSessionNumberWhenShown: 5,
    hasBeenClicked: true,
    numberOfTimesShown: 2,
  );

  const ctaValue = CTA(
    surveyBanner: surveyBannerValue,
    countrySelection: countrySelectionValue,
    sourceSelection: sourceSelectionValue,
    pushNotifications: pushNotificationsValue,
    topics: topicsValue,
  );

  const ctaMap = {
    0: surveyBannerMap,
    1: sourceSelectionMap,
    2: countrySelectionMap,
    3: pushNotificationsMap,
    4: topicsMap,
  };

  setUp(() async {
    mockMapToAppVersionMapper = MockMapToAppVersionMapper();
    mockAppVersionToMapMapper = MockAppVersionToMapMapper();
    mockOnboardingToMapMapper = MockOnboardingStatusToDbEntityMapMapper();
    mockMapToOnboardingMapper = MockDbEntityMapToOnboardingStatusMapper();
    mockInLineCardMapper = MockInLineCardMapper();
    mockDbEntityMapToSurveyBannerMapper =
        MockDbEntityMapToSurveyInLineCardMapper();
    mockDbEntityMapToCountrySelectionInLineCardMapper =
        MockDbEntityMapToCountrySelectionInLineCardMapper();
    mockDbEntityMapToSourceSelectionInLineCardMapper =
        MockDbEntityMapToSourceSelectionInLineCardMapper();
    mockDbEntityMapToPushNotificationsInLineCardMapper =
        MockDbEntityMapToPushNotificationsInLineCardMapper();
    mockDbEntityMapToTopicsInLineCardMapper =
        MockDbEntityMapToTopicsInLineCardMapper();

    ctaMapToDbEntityMapper = CTAMapToDbEntityMapper(
      mockInLineCardMapper,
    );

    dbEntityMapToCTAMapper = DbEntityMapToCTAMapper(
      mockDbEntityMapToSurveyBannerMapper,
      mockDbEntityMapToCountrySelectionInLineCardMapper,
      mockDbEntityMapToSourceSelectionInLineCardMapper,
      mockDbEntityMapToPushNotificationsInLineCardMapper,
      mockDbEntityMapToTopicsInLineCardMapper,
    );

    mapper = AppStatusMapper(
      mockMapToAppVersionMapper,
      mockAppVersionToMapMapper,
      mockOnboardingToMapMapper,
      mockMapToOnboardingMapper,
      ctaMapToDbEntityMapper,
      dbEntityMapToCTAMapper,
    );
  });

  group('AppStatusMapper tests: ', () {
    test('fromMap', () {
      when(mockMapToAppVersionMapper.map(appVersionMap))
          .thenReturn(appVersionValue);
      when(mockMapToOnboardingMapper.map(onboardingMap))
          .thenReturn(onboardingValue);
      when(mockDbEntityMapToSurveyBannerMapper.map(surveyBannerMap))
          .thenReturn(surveyBannerValue);
      when(mockDbEntityMapToSourceSelectionInLineCardMapper
              .map(sourceSelectionMap))
          .thenReturn(sourceSelectionValue);
      when(mockDbEntityMapToCountrySelectionInLineCardMapper
              .map(countrySelectionMap))
          .thenReturn(countrySelectionValue);
      when(mockDbEntityMapToPushNotificationsInLineCardMapper
              .map(pushNotificationsMap))
          .thenReturn(pushNotificationsValue);
      when(mockDbEntityMapToTopicsInLineCardMapper.map(topicsMap))
          .thenReturn(topicsValue);

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
          extraTrialEndDate: null,
          usedPromoCodes: {},
          userDidChangePushNotificationsStatus: false,
        ),
      );
    });

    test('toMap', () {
      when(mockAppVersionToMapMapper.map(appVersionValue))
          .thenReturn(appVersionMap);
      when(mockOnboardingToMapMapper.map(onboardingValue))
          .thenReturn(onboardingMap);

      when(mockInLineCardMapper.map(ctaValue.surveyBanner))
          .thenAnswer((realInvocation) => surveyBannerMap);
      when(mockInLineCardMapper.map(ctaValue.countrySelection))
          .thenAnswer((realInvocation) => countrySelectionMap);
      when(mockInLineCardMapper.map(ctaValue.sourceSelection))
          .thenAnswer((realInvocation) => sourceSelectionMap);
      when(mockInLineCardMapper.map(ctaValue.pushNotifications))
          .thenAnswer((realInvocation) => pushNotificationsMap);
      when(mockInLineCardMapper.map(ctaValue.topics))
          .thenAnswer((realInvocation) => topicsMap);

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
        usedPromoCodes: {},
        extraTrialEndDate: null,
        userDidChangePushNotificationsStatus: false,
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
        AppStatusFields.extraTrialDate: null,
        AppStatusFields.usedPromoCodes: [],
        AppStatusFields.userDidChangePushNotificationsStatus: false,
      };
      expect(map, expectedMap);
    });
  });
}
