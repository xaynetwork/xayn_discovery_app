import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';

void main() {
  const version = '1.2.3';
  const build = '321';
  test(
    'GIVEN two strings WHEN create AppVersion THEN verify values are equal',
    () {
      const appVersion = AppVersion(version: version, build: build);

      expect(appVersion.version, equals(version));
      expect(appVersion.build, equals(build));
    },
  );
  test(
    'GIVEN params WHEN create AppVersion THEN verify toString is correct',
    () {
      const appVersion = AppVersion(version: version, build: build);

      expect(appVersion.toString(), 'Version: $version, build: $build');
    },
  );

  test(
    'GIVEN two AppVersions WHEN second version is grater THEN the second AppVersion is greater',
    () {
      const appVersion1 = AppVersion(version: '1.0.0', build: '1');
      const appVersion2 = AppVersion(version: '1.0.1', build: '1');

      expect(appVersion2, greaterThan(appVersion1));
    },
  );

  test(
    'GIVEN two AppVersions WHEN both versions are teh same THEN both AppVersion are the same',
    () {
      const appVersion1 = AppVersion(version: '1.2.3', build: '1');
      const appVersion2 = AppVersion(version: '1.2.3', build: '1');

      expect(appVersion2, equals(appVersion1));
    },
  );
}
