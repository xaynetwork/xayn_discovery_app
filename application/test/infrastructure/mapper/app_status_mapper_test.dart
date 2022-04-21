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

  const onboardingMap = {
    0: 'hi there',
  };
  final onboardingValue = OnboardingStatus.initial();

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
      when(mockMapToAppVersionMapper.map({0: '1.0.0', 1: '123'})).thenAnswer(
        (_) => const AppVersion(version: '1.0.0', build: '123'),
      );
      when(mockMapToOnboardingMapper.map(onboardingMap))
          .thenReturn(onboardingValue);

      final map = {
        0: 10,
        1: {0: '1.0.0', 1: '123'},
        2: now,
        3: 'userId',
        4: lastSeen,
        AppSettingsFields.onboardingStatus: onboardingMap,
      };
      final appStatus = mapper.fromMap(map);
      expect(
        appStatus,
        AppStatus(
          numberOfSessions: 10,
          lastKnownAppVersion: const AppVersion(version: '1.0.0', build: '123'),
          firstAppLaunchDate: now,
          userId: const UniqueId.fromTrustedString('userId'),
          lastSeenDate: lastSeen,
          onboardingStatus: OnboardingStatus.initial(),
        ),
      );
    });

    test('toMap', () {
      when(mockAppVersionToMapMapper
              .map(const AppVersion(version: '1.0.0', build: '123')))
          .thenAnswer(
        (_) => {
          0: '1.0.0',
          1: '123',
        },
      );
      when(mockOnboardingToMapMapper.map(onboardingValue))
          .thenReturn(onboardingMap);

      final appStatus = AppStatus(
        numberOfSessions: 10,
        lastKnownAppVersion: const AppVersion(version: '1.0.0', build: '123'),
        firstAppLaunchDate: now,
        userId: const UniqueId.fromTrustedString('userId'),
        lastSeenDate: lastSeen,
        onboardingStatus: onboardingValue,
      );
      final map = mapper.toMap(appStatus);
      final expectedMap = {
        0: 10,
        1: {
          0: '1.0.0',
          1: '123',
        },
        2: now,
        3: 'userId',
        4: lastSeen,
        AppSettingsFields.onboardingStatus: onboardingMap,
      };
      expect(map, expectedMap);
    });
  });
}
