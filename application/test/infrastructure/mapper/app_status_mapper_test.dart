import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_status_mapper.dart';

import '../../test_utils/utils.dart';

void main() {
  late AppStatusMapper mapper;

  late MockMapToAppVersionMapper mockMapToAppVersionMapper;
  late MockAppVersionToMapMapper mockAppVersionToMapMapper;
  late MockOnboardingStatusToDbEntityMapMapper mockOnboardingToMapMapper;
  late MockDbEntityMapToOnboardingStatusMapper mockMapToOnboardingMapper;

  final now = DateTime.now();
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

  setUp(() async {
    mockMapToAppVersionMapper = MockMapToAppVersionMapper();
    mockAppVersionToMapMapper = MockAppVersionToMapMapper();
    mockOnboardingToMapMapper = MockOnboardingStatusToDbEntityMapMapper();
    mockMapToOnboardingMapper = MockDbEntityMapToOnboardingStatusMapper();

    mapper = AppStatusMapper(
      mockMapToAppVersionMapper,
      mockAppVersionToMapMapper,
      mockOnboardingToMapMapper,
      mockMapToOnboardingMapper,
    );
  });

  group('AppSettingsMapper tests: ', () {
    test('fromMap', () {
      when(mockMapToAppVersionMapper.map(appVersionMap))
          .thenReturn(appVersionValue);
      when(mockMapToOnboardingMapper.map(onboardingMap))
          .thenReturn(onboardingValue);

      final map = {
        AppSettingsFields.numberOfSessions: numberOfSessions,
        AppSettingsFields.appVersion: appVersionMap,
        AppSettingsFields.firstAppLaunchDate: now,
        AppSettingsFields.userId: userIdValue,
        AppSettingsFields.lastSeenDate: lastSeen,
        AppSettingsFields.onboardingStatus: onboardingMap,
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
        ),
      );
    });

    test('toMap', () {
      when(mockAppVersionToMapMapper.map(appVersionValue))
          .thenReturn(appVersionMap);
      when(mockOnboardingToMapMapper.map(onboardingValue))
          .thenReturn(onboardingMap);

      final appStatus = AppStatus(
        numberOfSessions: numberOfSessions,
        lastKnownAppVersion: appVersionValue,
        firstAppLaunchDate: now,
        userId: const UniqueId.fromTrustedString(userIdValue),
        lastSeenDate: lastSeen,
        onboardingStatus: onboardingValue,
      );
      final map = mapper.toMap(appStatus);
      final expectedMap = {
        AppSettingsFields.numberOfSessions: numberOfSessions,
        AppSettingsFields.appVersion: appVersionMap,
        AppSettingsFields.firstAppLaunchDate: now,
        AppSettingsFields.userId: userIdValue,
        AppSettingsFields.lastSeenDate: lastSeen,
        AppSettingsFields.onboardingStatus: onboardingMap,
      };
      expect(map, expectedMap);
    });
  });
}
