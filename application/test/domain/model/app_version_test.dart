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
}
