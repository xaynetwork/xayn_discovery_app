import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_status_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';

import 'app_status_mapper_test.mocks.dart';

@GenerateMocks([
  MapToAppVersionMapper,
  AppVersionToMapMapper,
])
void main() {
  late AppStatusMapper mapper;

  late MockMapToAppVersionMapper mockMapToAppVersionMapper;
  late MockAppVersionToMapMapper mockAppVersionToMapMapper;

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
      };
      final appStatus = mapper.fromMap(map);
      expect(
        appStatus,
        AppStatus.global(
          numberOfSessions: 10,
          appVersion: const AppVersion(version: '1.0.0', build: '123'),
        ),
      );
    });

    test('toMap', () {
      when(mockAppVersionToMapMapper
              .map(const AppVersion(version: '1.0.0', build: '123')))
          .thenAnswer(
        (_) => {0: '1.0.0', 1: '123'},
      );

      final appStatus = AppStatus.global(
        numberOfSessions: 10,
        appVersion: const AppVersion(version: '1.0.0', build: '123'),
      );
      final map = mapper.toMap(appStatus);
      final expectedMap = {
        0: 10,
        1: {0: '1.0.0', 1: '123'},
      };
      expect(map, expectedMap);
    });
  });
}
