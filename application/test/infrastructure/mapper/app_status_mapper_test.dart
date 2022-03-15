import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_status_mapper.dart';

import '../../presentation/test_utils/utils.dart';

void main() {
  late AppStatusMapper mapper;

  late MockMapToAppVersionMapper mockMapToAppVersionMapper;
  late MockAppVersionToMapMapper mockAppVersionToMapMapper;

  final now = DateTime.now();

  setUp(() async {
    mockMapToAppVersionMapper = MockMapToAppVersionMapper();
    mockAppVersionToMapMapper = MockAppVersionToMapMapper();

    mapper = AppStatusMapper(
      mockMapToAppVersionMapper,
      mockAppVersionToMapMapper,
    );
  });

  group('AppSettingsMapper tests: ', () {
    test('fromMap', () {
      when(mockMapToAppVersionMapper.map({0: '1.0.0', 1: '123'})).thenAnswer(
        (_) => const AppVersion(version: '1.0.0', build: '123'),
      );

      final map = {
        0: 10,
        1: {0: '1.0.0', 1: '123'},
        2: now,
      };
      final appStatus = mapper.fromMap(map);
      expect(
        appStatus,
        AppStatus(
          numberOfSessions: 10,
          lastKnownAppVersion: const AppVersion(version: '1.0.0', build: '123'),
          firstAppLaunchDate: now,
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

      final appStatus = AppStatus(
        numberOfSessions: 10,
        lastKnownAppVersion: const AppVersion(version: '1.0.0', build: '123'),
        firstAppLaunchDate: now,
      );
      final map = mapper.toMap(appStatus);
      final expectedMap = {
        0: 10,
        1: {
          0: '1.0.0',
          1: '123',
        },
        2: now,
      };
      expect(map, expectedMap);
    });
  });
}
